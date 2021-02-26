import $ from 'jquery';

function add_to_selected_tags(e) {
  var text = e.target[e.target.selectedIndex].text
  var id = e.target.value
  if (document.getElementById(text + "-tag") == null && text) {
    var tag_html = "<span type='select' class='tag is-medium' value=" + id + " id=" + text + "-tag>" + 
                      text + 
                      "<button type='button' class='delete is-small' id='tag-delete'></button>" + 
                      "<input type='hidden' name='node[tag_decl_ids][]' multiple=true value=" + id + ">" + 
                   "</span> "
    $('.field#selected-tags').append(tag_html)
  }
}

function remove_from_selected_tags(e) {
  e.target.parentElement.remove()
}

$(() => 
  $('.select#tags-select').on('change', (e) => add_to_selected_tags(e))
);

$(() => 
  $('body').on('click', 'button#tag-delete', (e) => remove_from_selected_tags(e))
);
