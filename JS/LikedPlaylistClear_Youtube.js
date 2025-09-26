function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function deleteLikedVideos() {
  "use strict";
  var videoContainers = document.querySelectorAll(
    "ytd-playlist-video-renderer"
  );
  for (var i = 0; i < videoContainers.length; i++) {
    var button = videoContainers[i].querySelector(
      "yt-icon-button.dropdown-trigger"
    );
    if (button) {
      console.log("Clicking the button to open the menu...");
      button.click();
      await sleep(500);

      var removeButton = document.evaluate(
        '//*[@id="items"]/ytd-menu-service-item-renderer[5]/tp-yt-paper-item',
        document,
        null,
        XPathResult.FIRST_ORDERED_NODE_TYPE,
        null
      ).singleNodeValue;

      if (removeButton) {
        console.log('Clicking the "Remove from Liked videos" button...');
        removeButton.click();
        await sleep(500); 

        var confirmationButton = document.querySelector(
          "paper-button.style-scope.yt-button-renderer.style-text"
        );
        if (confirmationButton) {
          console.log("Confirming removal...");
          confirmationButton.click();
          await sleep(500);
        }
        console.log("Video removed successfully.");
      } else {
        console.log('Unable to find "Remove from Liked videos" button.');
      }
    } else {
      console.log("Unable to find dropdown trigger button.");
    }
    await sleep(500);
  }
}