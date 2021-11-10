//setup before functions
var typingTimer;                //timer identifier
var doneTypingInterval = 500;  

/**
 * Method to fire once user stop writing
 */
function keyPressedOnLookup(componentId, objectName, fieldNames, fieldsPattern, photo, objectPluralName, remoteMethod, jsfunction, additionalFilter, spinner, mainRecordId){
    clearTimeout(typingTimer);
    var selector = '#'+componentId;
    if (document.querySelector(selector+" #lookup").value) {
        typingTimer = setTimeout(startSearch(componentId, objectName, fieldNames, fieldsPattern, photo, objectPluralName, remoteMethod, jsfunction, additionalFilter, spinner, mainRecordId), doneTypingInterval);
    }else{
        var lstBox = document.querySelector(selector+" #list-box");
        lstBox.style.display = 'none';
    }
}

/**
 * Function to get users from servers to display for Reviewers
 */
function startSearch(componentId, objectName, fieldNames, fieldsPattern, photo, objectPluralName, remoteMethod, jsfunction, additionalFilter, spinner, mainRecordId) {
    var selector = '#'+componentId;
    var searchText = document.querySelector(selector+" #lookup");
    Visualforce.remoting.Manager.invokeAction(remoteMethod,
            objectName, fieldNames, fieldsPattern, photo, searchText.value, '', jsfunction, additionalFilter,
        function(result, event){
            if (event.status) {
                var lstBox = document.querySelector(selector+" #list-box");
                lstBox.style.display = 'block';
                
                var recordLst = document.querySelector(selector+" #record-list");
                recordLst.innerHTML = '';
                for(var i = 0; i < result.length ; i++){
                    var record = result[i];
                    recordLst.appendChild(createRecordLi(componentId,record,objectName, spinner, mainRecordId));
                }
                document.querySelector(selector+" #search-text-info").innerHTML = searchText.value + ' in '+objectPluralName+' - '+ result.length + ' results found'; 
            } else if (event.type === 'exception') {
                    console.log(event.message);
                    console.log(event.where);
            } else {
                 console.log(event.message);
            }
        }, 
        {escape: true}
    );
}

/**
 * Create li for every record to display
 * @param  user
 * @return li
 */
function createRecordLi(componentId,record,objectName,spinner,mainRecordId){
    var id = record.recordId;
    var displayName = record.displayValue;
    var photoUrl = record.photoUrl;
    var li = document.createElement("li");
    var jsfunction = record.jsfunction;
    li.setAttribute("class", "slds-lookup__item");
    li.setAttribute("onclick", "select('"+componentId+"', '"+displayName+"', '"+photoUrl+"', '"+id+"', '"+jsfunction+"', '"+objectName.toLowerCase()+"', "+ spinner + ", '" + mainRecordId + "')");
    var inner = '<a id=s02 role=option>';
        if(photoUrl){
            inner += '<img src="'+photoUrl+'" class="slds-icon slds-icon-standard-'+objectName.toLowerCase()+' slds-icon--small"/>';
        }
        inner += displayName;
        inner += '</a>';
    
    li.innerHTML = inner;
    return li;
}

/**
 * Select record from list
 * @param  {[type]} displayName     [description]
 * @param  {[type]} photoUrl [description]
 * @param  {[type]} id       [description]
 * @return {[type]}          [description]
 */
function select(componentId, name,photoUrl,id, javascriptMethod, objectName, spinner, mainRecordId){
    var selector = '#'+componentId;
    if (spinner) {
        showSpinner();
    }
    document.querySelector(selector+" #selected-name").innerHTML = '<img src=""  class="slds-icon slds-icon-standard-'+objectName+' slds-pill__icon" id="select-image"/>' + name;
    if(photoUrl !== 'undefined' && photoUrl !== '' && photoUrl !== null){
        document.querySelector(selector+" #select-image").style.display = 'inline';
        document.querySelector(selector+" #select-image").setAttribute("src", photoUrl);
    }else{
        document.querySelector(selector+" #select-image").style.display = 'none';
    }
   
   document.querySelector('input[data-id=set'+ componentId +'Id]').value = id;
   recordSelected(componentId);
    if(javascriptMethod !== ''){
        this[javascriptMethod](id, mainRecordId);
    }
	return false;
}

/**
 * User selected function
 * @return {[type]} [description]
 */
function recordSelected(componentId){
    var selector = '#'+componentId;
    if(document.querySelector(selector+" #selected-record").style.display === 'none'){
        document.querySelector(selector+" #selected-record").style.display = 'block';
        document.querySelector(selector+" #input-text").style.display = 'none';
        document.querySelector(selector+" #lookup").style.display = 'none';
        document.querySelector(selector+" #lookup").value = '';
        var lstBox = document.querySelector(selector+" #list-box");
        lstBox.style.display = 'none';
    }else{
        document.querySelector(selector+" #input-text").style.display = 'block';
        document.querySelector(selector+" #selected-record").style.display = 'none';
        document.querySelector(selector+" #lookup").style.display = 'block';
    }
}

/**
 * remove selected record
 * @return {[type]} [description]
 */
function removeRecord(componentId, javascriptMethod, spinner, mainRecordId){
    document.querySelector('input[data-id=set'+ componentId +'Id]').value = null;
    recordSelected(componentId);
    if(javascriptMethod !== ''){
        if (spinner) {
            showSpinner();
        }
        this[javascriptMethod](null, mainRecordId);
    }
}
