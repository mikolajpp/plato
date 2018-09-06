
var ace = require('brace');
require('brace/ext/language_tools.js');
ace.acequire('brace/ext/language_tools.js');
require('lib/js/mode-hoon.js');
require('lib/js/plato-dark.js')
require('brace/theme/monokai');
//require('typeface-share-tech-mono');

function freshPayload(){
  return {
    id: null,
    content: null,
    session_name: null,
    row: null,
    col: null,
    call: null
  }
}
function spawn(app, editors, payload){

  // spawn new editor
  var newPayload = freshPayload();
  newPayload.id = payload.id;
  newPayload.call = "spawn";

  editor = ace.edit(payload.id);

  editor.$blockScrolling = 1;
  editor.$useWorker = false;

  editors[payload.id] = editor;
  console.log("Spawning new editor!");
  editor.setTheme("ace/theme/plato-dark");
  editor.setOptions({
    fontSize: "15px"
  });

  editor.getSession().setMode("ace/mode/hoon");
  // Disable web worker, as we handle annotations
  editor.getSession().setOption("useWorker", false)

  // Set up content update messages
  editor.on("change", function (o)
  {
    var newPayload = freshPayload();
    newPayload.id = payload.id;
    newPayload.content = editors[newPayload.id].getValue();
    newPayload.call = "get-content";

    app.ports.recv.send(newPayload);

  });

  // editor sessions
  editor.sessions = {}
  console.log("NewPayload = ", newPayload);
  app.ports.recv.send(newPayload);
}

function get_content(app,editors, payload)
{
  let editor = editors[payload.id]
  if(editor){

     var newPayload = freshPayload();
     newPayload.content = editor.getValue();
     newPayload.call = "get-content";

     app.ports.recv.send(newPayload);
   }
}

function set_content(app,editors, payload)
{
  let editor = editors[payload.id];

  if(editor){
    cur_session = editor.getSession();
    cur_session.setValue(payload.content);
    editor.setValue(payload.content);
  }
}

function lock(app,editors, payload)
{
  if(editors[payload.id]){
    editors[payload.id].setReadOnly(true);
  }
}

function resize(app, editors, payload)
{
  if(editors[payload.id]){
    editors[payload.id].resize();
  }
}

function annotate(app, editors, payload)
{
  if(editors[payload.id]){
    editors[payload.id].getSession().setAnnotations([{
      row: payload.row,
      column: payload.col,
      text: payload.text,
      type: payload.type
    }]);
  }
}

function clear_annotation(app, editors, payload)
{
  if(editors[payload.id]){
    editors[payload.id].getSession().clearAnnotations();
  }
}

function activate_error_marker(app, editors, payload)
{
  if(editors[payload.id]){

    editor = editors[payload.id];

    if('err_marker_id' in editor){
      editor.getSession().removeMarker(editor.err_marker_id);
    }

    var Range = ace.acequire('ace/range').Range;
    marker_start = payload.start;
    marker_end = payload.end;

     if(marker_start.row == marker_end.row &&
        marker_start.col == marker_end.col){
          marker_end.col += 1;
        }
    var range = new Range(marker_start.row,
                          marker_start.col,
                          marker_end.row,
                          marker_end.col);
    var marker = editor.getSession().addMarker(range, "error-marker","character");
    editors[payload.id].err_marker_id = marker;
  }
}

function clear_error_marker(app, editors, payload)
{
  editor = editors[payload.id];
  if(editor){
    if('err_marker_id' in editor){
      editor.getSession().removeMarker(editor.err_marker_id);
      delete editor.err_marker_id;
    }
  }
}

function new_session(app, editors, payload)
{
  let editor = editors[payload.id];

  if(editor){

    var newPayload = freshPayload();
    newPayload.id = payload.id;
    newPayload.call = "new-session";
    newPayload.session_name = payload.session_name;

    var EditSession = ace.acequire('ace/edit_session').EditSession;
    newSession = new EditSession(payload.content);
    editor.sessions[payload.session_name] = newSession;
    console.log("NewPayload (session) = ", newPayload);
    app.ports.recv.send(newPayload);

  }

}

function change_session(app, editors, payload)
{
  let editor = editors[payload.id];

  if(editor) {
    newPayload = freshPayload();
    newPayload.id= payload.id;
    newPayload.call = "change-session";
    newPayload.session_name = payload.session_name;

    editor.setSession(editor.sessions[payload.session_name]);
    editor.getSession().setMode("ace/mode/hoon");

    var selection = editor.getSelection();

    this.editor = editor;
    this.editor_id = payload.id

    selection.on("changeCursor",
     () => {
       var newPayload = freshPayload();
       newPayload.id = this.editor_id;
       newPayload.content = this.editor.getValue();
       var cur = editor.getCursorPosition();
       newPayload.row = cur.row + 1;
       newPayload.col = cur.column + 1;
       newPayload.call = "change-cursor";
      // console.log("editor = ", editor, "payload = ", payload);
       app.ports.recv.send(newPayload);
     });

    app.ports.recv.send(newPayload);

  }
}

function delete_session(app, editors, payload)
{
  editor = editors[payload.id];
  if(editor){
    var sn = payload.session_name;
    delete editor.sessions.sn;
    app.ports.recv.send(payload);
  }

}
editorApi =
{
  'spawn' : spawn,

  'get-content' : get_content,
  'set-content' : set_content,

  'lock' : lock,
  'resize' : resize,

  'annotate' : annotate,
  'clear-annotation' : clear_annotation,

  'activate-error-marker' : activate_error_marker,
  'clear-error-marker' : clear_error_marker,

  'new-session' : new_session,
  'change-session' : change_session,
  'delete-session' : delete_session
}

function init(elmApp)
{
  editors = {};
  elmApp.ports.send.subscribe(function (payload)
  {
      console.log(payload);
     // normalize
     if(! ('content' in payload)) {
       payload.content = null;
     }
     if(! ('session_name' in payload)) {
       payload.session_name = null;
     }

     (editorApi[payload.call])(elmApp, editors, payload);
     //payload = null;
  });
}

module.exports = {
  init: init
}
