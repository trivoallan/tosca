
// TODO : make a Tosca JS class ?

function tosca_remove(dom_id) {
	new Effect.Fade(dom_id,{duration:0.5});
	setTimeout(function() {
		Element.remove(dom_id);
    }, 500);
}

function tosca_reset(dom_id) {
	setTimeout(function() {
		$(dom_id).value = '';
    }, 1);
}


function tosca_toggle_comment(div_id) {
	if ($(div_id).hasClassName('collapsed')) {
		$(div_id).removeClassName('collapsed');
	} else {
		$(div_id).addClassName('collapsed');
	}
}

function tosca_expand_all_comments() {
 $$('div.comment-container').invoke('removeClassName', 'collapsed');
}

function tosca_collapse_all_comments() {
 $$('div.comment-container').invoke('addClassName', 'collapsed');
}

function tosca_generate_hash(id) {
  var now = new Date().getTime();
  var rand = Math.random() * now;
  var text = 'tosca' + now + rand;
  $(id).value = hex_md5(text);
  return true;
}