/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Cls = (ELMO.Views.ResponseFormRepeatView = class ResponseFormRepeatView extends ELMO.Views.ApplicationView {
  static initClass() {
    this.prototype.events = {
      'click > .add-repeat': 'addRepeat',
      'click .remove-repeat': 'removeRepeat'
    };
  }

  initialize(options) {
    this.tmpl = options.tmpl;
    this.next_index = options.next_index;

    // If this ID remains in the DOM and a new copy of the template is inserted,
    // the Backbone view instance for the newly inserted one won't know which of
    // them to bind to
    this.$el.removeAttr("id");

    return this.toggleEmptyNotice();
  }

  children() {
    return this.$("> .children");
  }

  addRepeat(event) {
    event.preventDefault();
    this.children().append(this.tmpl.replace(/__INDEX__/g, this.next_index));
    this.toggleEmptyNotice();
    return this.next_index++;
  }

  removeRepeat(event) {
    event.preventDefault();
    const node = $(event.target).closest(".node");

    const id = node.find('input[name$="[id]"]').first().val();
    if (id === "") {
      node.remove();
    } else {
      node.hide();
      node.find('input[name$="[_destroy]"]').first().val("true");
    }

    return this.toggleEmptyNotice();
  }

  toggleEmptyNotice() {
    return this.$("> .empty-notice").toggle(this.children().find(":visible").length === 0);
  }
});
Cls.initClass();
