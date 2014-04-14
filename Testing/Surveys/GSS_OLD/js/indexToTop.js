$(document).ready(function() {
            // Show or hide the sticky footer button
            $(window).scroll(function() {
                if ($(this).scrollTop() > 1000) {
                    $('.go-top').fadeIn(200);
                } else {
                    $('.go-top').fadeOut(200);
                }
            });
            
            // Animate the scroll to top
            $('.go-top').click(function(event) {
                event.preventDefault();

                //Reset the hash
                window.location.hash = '';
                
                $('html, body').animate({scrollTop: 0}, 300);
            })
        });