/**
 * Created by pablomartinez on 7/09/2019.
 */

({
    handleButtonPressed: function(cmp, event) {
        let actionClicked = event.getParam('actionClicked');

        const saveAndNew = event.getParam('saveAndNewVariable');

        if (saveAndNew) {
            actionClicked = "NEXT";
            cmp.set("v.saveAndNew", saveAndNew);
        }

        // Fire that action
        var navigate = cmp.get('v.navigateFlow');
        navigate(actionClicked);
    }
})