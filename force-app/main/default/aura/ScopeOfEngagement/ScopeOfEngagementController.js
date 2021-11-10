({
    doInit : function(component, event, helper) {
        window.addEventListener('message', function(evt) {
            helper.handleMessage(component, evt);
        });
	}
})