
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

function tosca_show_all_comments() {
 $$('div.comment-container').invoke('removeClassName', 'collapsed');
}