function setup_label() {
  if ($('label.filter_field input').length) {
    $('label.filter_field').each(function(){ 
        $(this).removeClass('c_on');
    });
    $('label.filter_field input:checked').each(function(){ 
        $(this).parent('label').addClass('c_on');
    });
  };
};

function submit_query() {
  var value = $.map($.makeArray($('#filter fieldset')), function(val, index) {
    var name = $(val).attr('data-field');
    var values = $.map($.makeArray($(val).find('label.filter_field input:checked')), function(param, i) {
      return $(param).val();
    });

    if (values.length) {
      return name + "=" + values.join(';');
    }
  }).join('|');

  var source_url = $('#filter input[name="source_url"]').val();
  var form = "<form action='" + $('form#filter').attr('action') + "' method='get' accept-charset='UTF-8'><input type='hidden' name='s' value='" + value + "'/><input type='hidden' name='source_url' value='" + source_url + "'/></form>";
  var $form = $(form);
  $form.appendTo('body').submit();
};

$(function() {
  $('label.filter_field').click(function(){
    setup_label();
  });
  setup_label();

  $('label.filter_value').click(function() {
    $(this).parent().find('input').click();
    setup_label();
  });

  $('label.filter_field input').click(function() {
    submit_query();
  });

  $('a.filter_clear_all').click(function() {
    $('#filter input:checked').removeAttr('checked');
    setup_label();
    return false;
  });
});
