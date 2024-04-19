 $(document).ready(function() {
 $("#logout").on("click", function(ev) {
            ev.preventDefault();
            window.location.search = window.location.search + "&logout=true";
           });
           
});             

/****************************
* END OF DOCUMENT READY   *
***************************
*/

                    