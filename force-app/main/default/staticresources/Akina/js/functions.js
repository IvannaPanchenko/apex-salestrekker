// JS_Common_Functions
function setDatePickers () {
    $('input[class*="date"]').each(function( ) {
        var params = {};
		
		if ($(this).change !== undefined) {
			params.onChange = (datepicker) => {
				$(this).trigger('change');
			}
		}
		
		$(this).datepicker(params);
    });
}

function validateMonths(x) {
    if ($(x).val() !== '') {
        var value = parseInt($(x).val());

        // validate min value
        if (value < 0) {
            $(x).val(0);
        } else {
            $(x).val(value);
        }
    }
}

// Pablo Martinez
// 08/07/2019
// function to handle the enter key as a tab and not submit the form
function handleKeyDown (event) {
    var elements = $(":input:not(.slds-button):not([type='checkbox']):enabled:not(:button):not([style*='display: none'])");
    var index = elements.index(event.target);
    if (event.keyCode === 13 || event.keyCode === 9) {
        event.preventDefault();
        elements.eq(index + 1).focus();
    }
}

function showConfirm(title, text, btnConfirmLabel, onClick) {
    var dialog = $('#confirmDialog');
    // title
    $(dialog).find('#dialog-heading-text').text(title);

    // text
    $('#dialog-content-body').html(text);

    // cancel button
    $(dialog).find('#dialog-buttons-cancel').removeClass('slds-hide');
    $(dialog).find('#dialog-buttons-cancel-title').removeClass('slds-hide');

    // confirmButton
    $(dialog).find('#dialog-buttons-confirm').html(btnConfirmLabel || 'OK');
    $(dialog).find("#dialog-buttons-confirm").off().on("click", () => {
        if (onClick) onClick();
        closeDialogconfirm();
        return false;
    });
    // open the dialog
    openDialog('confirm');
}

function showAlert (title, text) {
    var dialog = $('#confirmDialog');

    // title
    $(dialog).find('#dialog-heading-text').text(title);

    // text
    $('#dialog-content-body').html(text);

    // cancel button
    $(dialog).find('#dialog-buttons-cancel').addClass('slds-hide');
    $(dialog).find('#dialog-buttons-cancel-title').addClass('slds-hide');

    // confirm button
    $(dialog).find('#dialog-buttons-confirm').html('OK');
    $(dialog).find("#dialog-buttons-confirm").off().on("click", () => {
        closeDialogconfirm();
        return false;
    });

    // open the dialog
    openDialog('confirm');
}

function parseCurrency(num) {
    var a = parseFloat(num.replace(/,/g, ''))
    return a = a || 0;
}

function openSection(e, element) {

    if ($(e).parent().parent().hasClass('slds-is-open')) {
        $(e).parent().parent().removeClass('slds-is-open');
        $(e).parent().parent().find('.slds-section__content').hide();
    } else {
        $(e).parent().parent().parent().find('.slds-section').removeClass('slds-is-open');
        $(e).parent().parent().parent().find('.slds-section__content').hide();
        $(e).parent().parent().toggleClass('slds-is-open');
        $(e).parent().parent().find('.slds-section__content').show();
    }
}

function selectChkBox(element, unique, context, targetToShowHide) {
    var value = $(element).is(':checked');

    // if it's unique, uncheck the others
    if (unique && context) {
        var contextChkBoxes = $('#' + context);

        $(contextChkBoxes).find('input:checkbox').each((index, el) => {
            if (!$(element).is(el)) $(el).prop('checked', false);
        });
    }

    if (targetToShowHide) {
        if (value) {
            $('*[id*=' + targetToShowHide +']').addClass('slds-hide').removeClass('slds-show');
        }
        else {
            $('*[id*=' + targetToShowHide +']').removeClass('slds-hide').addClass('slds-show');
        }
    }
}

function showTooltip(cmp) {
    $('#' + cmp).removeClass('slds-fall-into-ground');
    $('#' + cmp).addClass('slds-rise-from-ground');
}

function hideTooltip(cmp) {
    $('#' + cmp).addClass('slds-fall-into-ground');
    $('#' + cmp).removeClass('slds-rise-from-ground');
}

function hideMessages() {
    setTimeout(function () {
        $('#pageMessages').fadeOut('slow');
    }, 3000);
}