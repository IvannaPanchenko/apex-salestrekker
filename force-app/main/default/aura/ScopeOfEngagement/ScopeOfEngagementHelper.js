({
	handleMessage : function(component, event) {
		var recordId = component.get( 'v.recordId' );
        var data = JSON.parse(event.data);
        
        if (data.recordId === recordId && data.action === 'refresh') {
            $A.get('e.force:refreshView').fire();
        }
	}
})