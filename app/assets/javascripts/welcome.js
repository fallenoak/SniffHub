$(function() {
  // Ensure dataTransfer property is passed to event handlers.
  jQuery.event.props.push('dataTransfer');

  $('.upload-target').on('dragover', function(e) {
    e.stopPropagation();
    e.preventDefault();

    $('.upload-target').addClass('dragover');
  });

  $('.upload-target').on('dragleave', function(e) {
    e.stopPropagation();
    e.preventDefault();

    $('.upload-target').removeClass('dragover');
  });

  $('.upload-target').on('drop', function(e) {
    e.stopPropagation();
    e.preventDefault();

    $('.upload-target').removeClass('dragover');
    $('.upload-queue').removeClass('hidden');

    var dt = e.dataTransfer;
    var files = dt.files;

    uploadFile(files[0]);
  });

  function uploadFile(file) {
    // Create a new uploads entry out of the template.
    var uploadHtml = $('.upload-target template').html();
    var uploadDom = $($.parseHTML(uploadHtml));

    uploadDom.find('.file-name').text(file.name);
    uploadDom.find('.file-size').text(filesize(file.size, { round: 1 }));

    $('.upload-target .upload-queue').prepend(uploadDom);

    // Grab handle to form DOM.
    var formDom = uploadDom.find('form');

    // Set up form data.
    var formData = new FormData(formDom.get(0));
    var uploadParam = formDom.attr('data-upload-param');
    formData.append(uploadParam, file);

    // Set up an XHR stub with progress callbacks.
    var customizedXhr = function() {
      var xhr = $.ajaxSettings.xhr();

      if (xhr.upload) {
        xhr.upload.addEventListener('progress', function(e) {
          if (!e.lengthComputable) {
            return;
          }

          var progress = e.loaded / e.total;
          updateProgress(uploadDom, progress);
        });
      } else {
        xhr.addEventListener('progress', function(e) {
          if (!e.lengthComputable) {
            return;
          }

          var progress = e.loaded / e.total;
          updateProgress(uploadDom, progress);
        });
      }

      return xhr;
    };

    // Fire off upload request.
    $.ajax({
      xhr: customizedXhr,
      processData: false,
      contentType: false,
      url: formDom.attr('action'),
      method: formDom.attr('method'),
      data: formData
    }).fail(function(xhr, status, error) {
      console.log('failed!');
      console.log(status);
      console.log(error);

      failUpload(uploadDom);
    }).done(function() {
      updateProgress(uploadDom, 100);
    });
  }

  function failUpload(uploadDom) {
    uploadDom.find('.progress').text('Failed!');
  }

  function updateProgress(uploadDom, progress) {
    var progressContent = '';

    if (progress >= 100.0) {
      progressContent = 'Complete!';
      progressState = 'completed';
    } else {
      progressContent = Math.round(progress * 100).toString() + '%';
      progressState = 'in-progress';
    }

    uploadDom.find('.upload-progress').text(progressContent);

    uploadDom.removeClass('completed');
    uploadDom.removeClass('in-progress');

    uploadDom.addClass(progressState);
  }
});
