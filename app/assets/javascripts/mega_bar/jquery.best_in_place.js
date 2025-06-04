/*
 * jQuery best_in_place
 * A jQuery plugin that makes any field in place editable with a click
 *
 * Copyright (c) 2011-2012 Bernat Farrero
 * Licensed under the MIT license.
 */

(function ($) {
    $.fn.best_in_place = function () {
        return this.each(function () {
            var $element = $(this);
            var bip = $element.data("bestInPlaceEditor");
            if (bip) return bip;
            bip = new $.bestInPlaceEditor(this);
            $element.data("bestInPlaceEditor", bip);
        });
    };

    $.bestInPlaceEditor = function (element) {
        this.element = element;
        this.$element = $(element);
        this.initOptions();
        this.bindForm();
        this.initNil();
        this.setupTrigger();
    };

    $.bestInPlaceEditor.prototype.initOptions = function () {
        this.options = $.extend({}, $.fn.best_in_place.defaults, this.$element.data('best-in-place'));
    };

    $.bestInPlaceEditor.prototype.bindForm = function () {
        this.$element.bind("click", this.activate.bind(this));
    };

    $.bestInPlaceEditor.prototype.initNil = function () {
        if (this.$element.text() === "") {
            this.$element.text(this.options.nil);
        }
    };

    $.bestInPlaceEditor.prototype.setupTrigger = function () {
        if (this.options.trigger) {
            this.$element.bind(this.options.trigger, this.activate.bind(this));
        }
    };

    $.bestInPlaceEditor.prototype.activate = function (event) {
        event.preventDefault();
        event.stopPropagation();
        if (this.isActive()) return;
        this.activateForm();
    };

    $.bestInPlaceEditor.prototype.isActive = function () {
        return this.$element.find('form').length > 0;
    };

    $.bestInPlaceEditor.prototype.activateForm = function () {
        var self = this;
        var $form = $('<form></form>');
        var $input = this.createInput();
        $form.append($input);
        this.$element.html($form);
        $input.focus();
        $input.select();
        $form.bind('submit', this.submit.bind(this));
        $input.bind('blur', this.submit.bind(this));
        $input.bind('keyup', function (e) {
            if (e.keyCode === 27) {
                self.abort();
            }
        });
    };

    $.bestInPlaceEditor.prototype.createInput = function () {
        var input = $('<input></input>');
        input.attr('type', 'text');
        input.attr('name', this.options.attribute);
        input.val(this.getCurrentValue());
        return input;
    };

    $.bestInPlaceEditor.prototype.getCurrentValue = function () {
        return this.$element.text();
    };

    $.bestInPlaceEditor.prototype.submit = function (event) {
        event.preventDefault();
        var self = this;
        var $input = this.$element.find('input');
        var newValue = $input.val();
        if (newValue === this.getCurrentValue()) {
            this.abort();
            return;
        }
        $.ajax({
            url: this.$element.data('url'),
            type: 'PUT',
            data: this.buildParams(newValue),
            success: function (data) {
                self.$element.html(newValue);
                self.$element.trigger('ajax:success', data);
            },
            error: function (data) {
                self.$element.html(self.getCurrentValue());
                self.$element.trigger('ajax:error', data);
            }
        });
    };

    $.bestInPlaceEditor.prototype.buildParams = function (newValue) {
        var params = {};
        params[this.options.attribute] = newValue;
        return params;
    };

    $.bestInPlaceEditor.prototype.abort = function () {
        this.$element.html(this.getCurrentValue());
    };

    $.fn.best_in_place.defaults = {
        attribute: null,
        trigger: null,
        nil: '-',
        url: null
    };
})(jQuery); 