/*global app */

const editor = require("./editor");
const schemas = require("./narrows-schemas");

/*
 * Ports for the reader app
 */

function bumpVolume(audioEl) {
    audioEl.volume = Math.min(1, audioEl.volume + 0.02);

    if (audioEl.volume < 1) {
        setTimeout(function() {
            bumpVolume(audioEl);
        }, 100);
    }
}

app.ports.renderText.subscribe(evt => {
    // Make sure the DOM elements are already rendered
    requestAnimationFrame(() => {
        const elem = document.getElementById(evt.elemId);
        if (!elem) {
            console.error("Cannot render text into " + evt.elemId +
                          ", element does not exist (yet?)");
            return;
        }
        elem.innerHTML = "";
        elem.appendChild(editor.exportTextToDOM(evt.text, schemas.chapter));
    });
});

app.ports.startNarration.subscribe(evt => {
    const breathHoldingTime = 700;

    // Make chapter fade-in after a short pause (breathHoldingTime
    // above)
    setTimeout(() => {
        app.ports.markNarrationAsStarted.send(breathHoldingTime);

        // Fade audio in, too
        if (!evt.audioElemId) {
            return;
        }
        const audioEl = document.getElementById(evt.audioElemId);
        if (!audioEl) {
            return;
        }
        audioEl.volume = 0.1;
        audioEl.play();
        bumpVolume(audioEl);
    }, breathHoldingTime);
});

app.ports.playPauseNarrationMusic.subscribe(evt => {
    const audioEl = document.getElementById(evt.audioElemId);
    if (audioEl.paused) {
        audioEl.play();
    } else {
        audioEl.pause();
    }
});

app.ports.flashElement.subscribe(elemId => {
    const el = document.getElementById(elemId);
    if (!el) {
        console.error(
            "Element", elemId, "doesn't exist (yet?), cannot flash it"
        );
        return;
    }
    el.style.display = "";
    setTimeout(() => {
        el.style.display = "none";
    }, 3000);
});

document.addEventListener("scroll", function(evt) {
    app.ports.pageScrollListener.send(window.scrollY);
}, false);

/*
 * Ports for the narrator app
 */
const editorViews = {};
app.ports.initEditor.subscribe(evt => {
    requestAnimationFrame(() => {
        const container = document.getElementById(evt.elemId);
        const schema = schemas[evt.editorType];

        // Avoid memory leaks: if there was an editor with the same name
        // from before, remove it.
        if (editorViews.hasOwnProperty(evt.elemId)) {
            const editorEl = editorViews[evt.elemId];

            while (container.firstChild) {
                container.removeChild(container.firstChild);
            }
            container.appendChild(editorEl.dom.parentNode);

            editor.updateText(editorEl, evt.text, schema);
        } else {
            editorViews[evt.elemId] =
                editor.create(evt.text, schema, container, view => {
                    const port = app.ports[evt.updatePortName];
                    if (port) {
                        port.send(editor.exportText(view));
                    } else {
                        console.error("Cannot find editor update port '" +
                                      evt.updatePortName + "'");
                    }
                });
        }
        editorViews[evt.elemId].props.narrationId = evt.narrationId;
        editorViews[evt.elemId].props.images = evt.narrationImages;
        editorViews[evt.elemId].props.participants = evt.chapterParticipants;
    });
});
app.ports.updateParticipants.subscribe(evt => {
    const editorInstance = editorViews[evt.editor];
    if (!editorInstance) {
        console.error(
            "Cannot update participants in " + evt.editor +
                " as it doesn't exist (yet?)"
        );
        return;
    }

    editor.updateParticipants(editorInstance, evt.participantList);
});
app.ports.playPauseAudioPreview.subscribe(audioElemId => {
    const audioEl = document.getElementById(audioElemId);
    if (!audioEl) {
        console.error("Cannot play audio in non-existent element", audioElemId);
        return;
    }

    if (audioEl.paused) {
        audioEl.play();
    } else {
        audioEl.pause();
    }
});
app.ports.openFileInput.subscribe(fileInputId => {
    const fileInput = document.getElementById(fileInputId);
    if (!fileInput) {
        console.error("Cannot open non-existent element", fileInputId);
        return;
    }

    fileInput.click();
});
app.ports.uploadFile.subscribe(evt => {
    const fileInput = document.getElementById(evt.fileInputId);
    const url = "/api/narrations/" + evt.narrationId + "/files";

    const xhr = new XMLHttpRequest();
    xhr.open("POST", url);
    xhr.addEventListener("load", function() {
        const resp = JSON.parse(this.responseText);

        if (this.status < 200 || this.status >= 400) {
            app.ports.uploadFileError.send({ status: this.status,
                                             message: resp.errorMessage });
            return;
        }

        app.ports.uploadFileSuccess.send({ name: resp.name,
                                           type_: resp.type });
    });

    const formData = new FormData();
    formData.append("file", fileInput.files[0]);
    xhr.send(formData);
});

app.ports.scrollTo.subscribe(evt => {
    window.scrollTo(0, evt);
});

app.ports.readAvatarAsUrl.subscribe(evt => {
    const file = document.getElementById(evt.fileInputId).files[0];
    if (!file) {
        return;
    }

    const reader = new FileReader();
    reader.addEventListener("load", function () {
        app.ports.receiveAvatarAsUrl.send(reader.result);
    }, false);

    reader.readAsDataURL(file);
});
app.ports.uploadAvatar.subscribe(evt => {
    const fileInput = document.getElementById(evt.fileInputId);
    const url = "/api/characters/" + evt.characterToken + "/avatar";

    const xhr = new XMLHttpRequest();
    xhr.open("PUT", url);
    xhr.addEventListener("load", function() {
        const resp = JSON.parse(this.responseText);

        if (this.status < 200 || this.status >= 400) {
            app.ports.uploadAvatarError.send({ status: this.status,
                                               message: resp.errorMessage });
            return;
        }

        // Fool the browser into thinking it's a new image
        const cheekyAvatarUrl = resp.avatar + "?" + (new Date()).getTime();
        app.ports.uploadAvatarSuccess.send(cheekyAvatarUrl);
    });

    const formData = new FormData();
    formData.append("avatar", fileInput.files[0]);
    xhr.send(formData);
});
