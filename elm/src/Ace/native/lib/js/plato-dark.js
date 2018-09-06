ace.define("ace/theme/plato-dark",["require","exports","module","ace/lib/dom"], function(acequire, exports, module) {

exports.isDark = true;
exports.cssClass = "ace-monokai";
exports.cssText = ".ace-monokai .ace_gutter {\
background: hsl(270,6%, 14%);\
color: #8F908A\
}\
.ace-monokai {\
font-family: \"Share Tech Mono\", monospace;\
}\
.ace-monokai .ace_print-margin {\
width: 1px;\
background: #555651\
}\
.ace-monokai {\
background-color: hsl(270, 6%, 14%);\
color: #F8F8F2\
}\
.ace-monokai .ace_cursor {\
color: #F8F8F0\
}\
.ace-monokai .ace_marker-layer .ace_selection {\
background: #49483E\
}\
.ace-monokai.ace_multiselect .ace_selection.ace_start {\
box-shadow: 0 0 3px 0px #272822;\
}\
.ace-monokai .ace_marker-layer .ace_step {\
background: rgb(102, 82, 0)\
}\
.ace-monokai .ace_marker-layer .ace_bracket {\
margin: -1px 0 0 -1px;\
border: 1px solid #49483E\
}\
.ace-monokai .ace_marker-layer .ace_active-line {\
background: #202020\
}\
.ace-monokai .ace_gutter-active-line {\
background-color: #202020\
}\
.ace-monokai .ace_marker-layer .ace_selected-word {\
border: 1px solid #49483E\
}\
.ace-monokai .ace_invisible {\
color: #52524d\
}\
.ace-monokai .ace_entity.ace_name.ace_tag,\
.ace-monokai .ace_keyword,\
.ace-monokai .ace_meta.ace_tag,\
.ace-monokai .ace_storage {\
color: #F92672\
}\
.ace-monokai .ace_punctuation,\
.ace-monokai .ace_punctuation.ace_tag {\
color: #fff\
}\
.ace-monokai .ace_constant.ace_character,\
.ace-monokai .ace_constant.ace_language,\
.ace-monokai .ace_constant.ace_numeric,\
.ace-monokai .ace_constant.ace_other {\
color: #AE81FF\
}\
.ace-monokai .ace_invalid {\
color: #F8F8F0;\
background-color: #F92672\
}\
.ace-monokai .ace_invalid.ace_deprecated {\
color: #F8F8F0;\
background-color: #AE81FF\
}\
.ace-monokai .ace_support.ace_constant,\
.ace-monokai .ace_support.ace_function {\
color: #66D9EF\
}\
.ace-monokai .ace_fold {\
background-color: #A6E22E;\
border-color: #F8F8F2\
}\
.ace-monokai .ace_storage.ace_type,\
.ace-monokai .ace_support.ace_class,\
.ace-monokai .ace_support.ace_type {\
font-style: italic;\
color: #66D9EF\
}\
.ace-monokai .ace_entity.ace_name.ace_function,\
.ace-monokai .ace_entity.ace_other,\
.ace-monokai .ace_entity.ace_other.ace_attribute-name,\
.ace-monokai .ace_variable {\
color: #A6E22E\
}\
.ace-monokai .ace_variable.ace_parameter {\
font-style: italic;\
color: #FD971F\
}\
.ace-monokai .ace_string {\
color: #E6DB74\
}\
.ace-monokai .ace_comment {\
color: #75715E\
}\
.ace-monokai .ace_tooltip {\
background-color: hsl(270,6%, 10%);\
color: white;\
}\
.ace_gutter-cell.ace_error {\
    background-image:url(\"data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhLS0gQ3JlYXRlZCB3aXRoIElua3NjYXBlIChodHRwOi8vd3d3Lmlua3NjYXBlLm9yZy8pIC0tPgoKPHN2ZwogICB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iCiAgIHhtbG5zOmNjPSJodHRwOi8vY3JlYXRpdmVjb21tb25zLm9yZy9ucyMiCiAgIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyIKICAgeG1sbnM6c3ZnPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIKICAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogICB4bWxuczpzb2RpcG9kaT0iaHR0cDovL3NvZGlwb2RpLnNvdXJjZWZvcmdlLm5ldC9EVEQvc29kaXBvZGktMC5kdGQiCiAgIHhtbG5zOmlua3NjYXBlPSJodHRwOi8vd3d3Lmlua3NjYXBlLm9yZy9uYW1lc3BhY2VzL2lua3NjYXBlIgogICB3aWR0aD0iODUuNTI2MjQ1bW0iCiAgIGhlaWdodD0iODUuNTI2MjQ1bW0iCiAgIHZpZXdCb3g9IjAgMCA4NS41MjYyNDUgODUuNTI2MjQ1IgogICB2ZXJzaW9uPSIxLjEiCiAgIGlkPSJzdmc4IgogICBpbmtzY2FwZTp2ZXJzaW9uPSIwLjkyLjIgMjQwNTU0NiwgMjAxOC0wMy0xMSIKICAgc29kaXBvZGk6ZG9jbmFtZT0iZ3V0dGVyLWVycm9yLWljb24uc3ZnIj4KICA8ZGVmcwogICAgIGlkPSJkZWZzMiIgLz4KICA8c29kaXBvZGk6bmFtZWR2aWV3CiAgICAgaWQ9ImJhc2UiCiAgICAgcGFnZWNvbG9yPSIjZmZmZmZmIgogICAgIGJvcmRlcmNvbG9yPSIjNjY2NjY2IgogICAgIGJvcmRlcm9wYWNpdHk9IjEuMCIKICAgICBpbmtzY2FwZTpwYWdlb3BhY2l0eT0iMC4wIgogICAgIGlua3NjYXBlOnBhZ2VzaGFkb3c9IjIiCiAgICAgaW5rc2NhcGU6em9vbT0iMC40OTQ5NzQ3NSIKICAgICBpbmtzY2FwZTpjeD0iLTUwMi4yMTkxNCIKICAgICBpbmtzY2FwZTpjeT0iMTU0LjYxMTkxIgogICAgIGlua3NjYXBlOmRvY3VtZW50LXVuaXRzPSJtbSIKICAgICBpbmtzY2FwZTpjdXJyZW50LWxheWVyPSJsYXllcjEiCiAgICAgc2hvd2dyaWQ9ImZhbHNlIgogICAgIGZpdC1tYXJnaW4tdG9wPSIwIgogICAgIGZpdC1tYXJnaW4tbGVmdD0iMCIKICAgICBmaXQtbWFyZ2luLXJpZ2h0PSIwIgogICAgIGZpdC1tYXJnaW4tYm90dG9tPSIwIgogICAgIGlua3NjYXBlOndpbmRvdy13aWR0aD0iMTkyMCIKICAgICBpbmtzY2FwZTp3aW5kb3ctaGVpZ2h0PSIxMDE2IgogICAgIGlua3NjYXBlOndpbmRvdy14PSIwIgogICAgIGlua3NjYXBlOndpbmRvdy15PSIyNyIKICAgICBpbmtzY2FwZTp3aW5kb3ctbWF4aW1pemVkPSIxIiAvPgogIDxtZXRhZGF0YQogICAgIGlkPSJtZXRhZGF0YTUiPgogICAgPHJkZjpSREY+CiAgICAgIDxjYzpXb3JrCiAgICAgICAgIHJkZjphYm91dD0iIj4KICAgICAgICA8ZGM6Zm9ybWF0PmltYWdlL3N2Zyt4bWw8L2RjOmZvcm1hdD4KICAgICAgICA8ZGM6dHlwZQogICAgICAgICAgIHJkZjpyZXNvdXJjZT0iaHR0cDovL3B1cmwub3JnL2RjL2RjbWl0eXBlL1N0aWxsSW1hZ2UiIC8+CiAgICAgICAgPGRjOnRpdGxlPjwvZGM6dGl0bGU+CiAgICAgIDwvY2M6V29yaz4KICAgIDwvcmRmOlJERj4KICA8L21ldGFkYXRhPgogIDxnCiAgICAgaW5rc2NhcGU6bGFiZWw9IkxheWVyIDEiCiAgICAgaW5rc2NhcGU6Z3JvdXBtb2RlPSJsYXllciIKICAgICBpZD0ibGF5ZXIxIgogICAgIHRyYW5zZm9ybT0idHJhbnNsYXRlKC01MC4yNDY2NzQsLTEwNy4yMzg2MykiPgogICAgPGNpcmNsZQogICAgICAgc3R5bGU9Im9wYWNpdHk6MTtmaWxsOiNkZjAwMDA7ZmlsbC1vcGFjaXR5OjAuOTYzODU1NDY7c3Ryb2tlOm5vbmU7c3Ryb2tlLXdpZHRoOjAuMjtzdHJva2UtbGluZWpvaW46cm91bmQ7c3Ryb2tlLW1pdGVybGltaXQ6NDtzdHJva2UtZGFzaGFycmF5Om5vbmU7c3Ryb2tlLWRhc2hvZmZzZXQ6MDtzdHJva2Utb3BhY2l0eToxO3BhaW50LW9yZGVyOm5vcm1hbCIKICAgICAgIGlkPSJwYXRoNDUxOCIKICAgICAgIGN4PSI5My4wMDk3OTYiCiAgICAgICBjeT0iMTUwLjAwMTc1IgogICAgICAgcj0iNDIuNzYzMTIzIiAvPgogIDwvZz4KPC9zdmc+Cg==\");\
    background-repeat: no-repeat;\
    background-position: 2px center;\
    background-size: 20%;\
}\
.error-marker {\
  position: absolute;\
  background: hsl(0, 99%, 30%);\
  z-index: 20\
}\
.ace-monokai .ace_indent-guide {\
background: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAACCAYAAACZgbYnAAAAEklEQVQImWPQ0FD0ZXBzd/wPAAjVAoxeSgNeAAAAAElFTkSuQmCC) right repeat-y\
}";

var dom = acequire("../lib/dom");
dom.importCssString(exports.cssText, exports.cssClass);
});
