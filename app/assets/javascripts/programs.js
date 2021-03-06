(function() {
  var updateCountryCode = function() {
    var country = $('#country').val();
    if (country !== "") {
      showMobile();
      $('#mobile').focus();
    } else {
      $('#mobile-wrapper').hide();
    }
  }

  var showMobile = function() {
    $('#mobile-code').html('+' + $('#country option:selected').data('code'));
    $('#mobile-wrapper').show();
  }

  var detectCountry = function(selector) {
    $.getJSON("//ipinfo.io")
      .done(function(response) {
        var country = response.country;
        var countries = $.map($('#country options'), function(option) {
          return option.value
        });
        if (countries.indexOf(country)) {
          $('#country').val(country);
          showMobile();
        } else {
          $('#country').val("");
          $('#mobile-wrapper').hide();
        }
      });

    $('#first-name').focus();
  };

  var initForm = function() {
    $('#form-start-now').on('submit', validateForm);
    $(document).on("page:before-change", function() {
      $('#form-start-now').off('submit');
    });

    detectCountry();
    $('#country').on('change', updateCountryCode);
    $(document).on("page:before-change", function() {
      $('#country').off('change');
    });
  };

  var validateField = function(selector, validFn, message) {
    var formGroup = selector.closest('.form-group');
    formGroup.removeClass("has-error");
    $('.help-block', formGroup).remove();

    var firstName = selector.val();
    if (!validFn(firstName)) {
      selector.closest('.form-group').addClass("has-error").append('<span class="help-block">' + message + '</span>');
      return false;
    }

    return true;
  }

  var isBlank = function(val) {
    return val.trim().length !== 0;
  };

  var isEmail = function(val) {
    return /(.+)@(.+){2,}\.(.+){2,}/.test(val);
  }

  var isMobile = function(val) {
    return /[0-9\-()\+\s]{7,20}/.test(val);
  }

  var validateForm = function() {
    var isValid = true;

    if (!validateField($('#first-name'), isBlank, "Campo requerido")) {
      $('#first-name').one('change', validateForm);
      isValid = false;
    }

    if (!validateField($('#last-name'), isBlank, "Campo requerido")) {
      $('#last-name').one('change', validateForm);
      isValid = false;
    }

    if (!validateField($('#email'), isBlank, "Campo requerido")) {
      $('#email').one('change', validateForm);
      isValid = false;
    } else if (!validateField($('#email'), isEmail, "Email inválido")) {
      $('#email').one('change', validateForm);
      isValid = false;
    }

    if (!validateField($('#country'), isBlank, "Campo requerido")) {
      $('#country').one('change', validateForm);
      isValid = false;
    }

    if (!validateField($('#mobile'), isBlank, "Campo requerido")) {
      $('#mobile').one('change', validateForm);
      isValid = false;
    } else if (!validateField($('#mobile'), isMobile, "Celular inválido")) {
      $('#mobile').one('change', validateForm);
      isValid = false;
    }

    return isValid;
  }

  window.initProgramPage = function() {
    initForm();

    $(window).on('scroll', function() {
      var scroll = $(window).scrollTop();
      if (scroll > 600) {
        $('.header-apply').slideDown();
      } else {
        $('.header-apply').slideUp();
      }
    });

    $('.btn-start-now').on('click', function(e) {
      e.preventDefault();
      $('html, body').animate({
        scrollTop: $("#form-start-now").offset().top - 60
      }, 1000);
      $('#first-name').focus();
    });
  };

})();
