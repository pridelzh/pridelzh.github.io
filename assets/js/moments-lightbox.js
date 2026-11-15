(function () {
  "use strict";

  var images = document.querySelectorAll(".moment-content img");

  if (!images.length || typeof HTMLDialogElement === "undefined") {
    return;
  }

  var dialog = document.createElement("dialog");
  dialog.className = "moment-lightbox";
  dialog.setAttribute("aria-label", "Image preview");
  dialog.innerHTML =
    '<div class="moment-lightbox-content">' +
    '<button class="moment-lightbox-close" type="button" aria-label="Close image preview">&times;</button>' +
    '<img alt="">' +
    "</div>";
  document.body.appendChild(dialog);

  var preview = dialog.querySelector("img");
  var closeButton = dialog.querySelector(".moment-lightbox-close");

  function closePreview() {
    if (dialog.open) {
      dialog.close();
    }
    preview.removeAttribute("src");
    document.body.classList.remove("lightbox-open");
  }

  function openPreview(image) {
    preview.src = image.currentSrc || image.src;
    preview.alt = image.alt || "Image preview";
    dialog.showModal();
    document.body.classList.add("lightbox-open");
  }

  images.forEach(function (image) {
    image.setAttribute("tabindex", "0");
    image.setAttribute("role", "button");
    image.setAttribute("aria-label", image.alt ? "Preview " + image.alt : "Preview image");
    image.addEventListener("click", function () {
      openPreview(image);
    });
    image.addEventListener("keydown", function (event) {
      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault();
        openPreview(image);
      }
    });
  });

  closeButton.addEventListener("click", closePreview);
  dialog.addEventListener("click", function (event) {
    if (event.target === dialog) {
      closePreview();
    }
  });
  dialog.addEventListener("cancel", function (event) {
    event.preventDefault();
    closePreview();
  });
  dialog.addEventListener("close", function () {
    document.body.classList.remove("lightbox-open");
  });
}());
