// Config: Delete field from include
function delInclExclEntry(id) {
	document.getElementById(id).remove();
}

//Add field to include config
function addIncludeEntry(id) {
	// Clone the element
	var includeEntryElement = document.getElementById("include_");
	var includeEntryClone = includeEntryElement.cloneNode(true);
	// Create the next id
	var next_id = parseInt(id)+1;
	// Change the ids in the element to be add
	includeEntryClone.classList.remove('d-none');
	includeEntryClone.id = "include_"+next_id;
	includeEntryClone.getElementsByTagName("input")[0].name = "include_"+next_id;
	includeEntryClone.getElementsByTagName("button").include_del.setAttribute("onclick","delInclExclEntry('include_" + next_id + "');");
	includeEntryClone.getElementsByTagName("button").include_del.disabled = false;
	// Add element to the page
	document.getElementById("include").append(includeEntryClone);
}

//Add field to exclude config
function addExcludeEntry(id) {
	// Clone the element
	var excludeEntryElement = document.getElementById("exclude_");
	var excludeEntryClone = excludeEntryElement.cloneNode(true);
	// Create the next id
	var next_id = parseInt(id)+1;
	// Change the ids in the element to be add
	excludeEntryClone.classList.remove('d-none');
	excludeEntryClone.id = "exclude_"+next_id;
	excludeEntryClone.getElementsByTagName("input")[0].name = "exclude_"+next_id;
	excludeEntryClone.getElementsByTagName("button").exclude_del.setAttribute("onclick","delInclExclEntry('exclude_" + next_id + "');");
	excludeEntryClone.getElementsByTagName("button").exclude_del.disabled = false;
	// Add element to the page
	document.getElementById("exclude").append(excludeEntryClone);
}

// Delete Host Config
function hostDelete(id) {
	document.getElementById("host_item_"+id).remove();
}

// Delete specific directory from backuped host
function hostDeleteDir(serverid, dirid) {
	document.getElementById("server_"+serverid+"_dir_"+dirid+"_entryGroup").remove();
}

//Add another directory for backup on specific host
function hostAddDir(serverid, dirid) {
	// Clone the element
	var newDirEntryElement = document.getElementById("new_dir_entry");
	var newDirEntryClone = newDirEntryElement.cloneNode(true);
	// Change the ids in the element to be add
	newDirEntryClone.classList.remove('d-none');
	newDirEntryClone.id = "server_"+serverid+"_dir_"+dirid+"_entryGroup";
	newDirEntryClone.getElementsByTagName("input")[0].name = "server_"+serverid+"_dir_"+dirid+"_dir";
	newDirEntryClone.getElementsByTagName("input")[0].id = "server_"+serverid+"_dir_"+dirid+"_dir";
	newDirEntryClone.getElementsByTagName("input")[1].name = "server_"+serverid+"_dir_"+dirid+"_args";
	newDirEntryClone.getElementsByTagName("input")[1].id = "server_"+serverid+"_dir_"+dirid+"_args";
	newDirEntryClone.getElementsByTagName("button").hostdir_del.disabled = false;
	newDirEntryClone.getElementsByTagName("button").hostdir_del.setAttribute("onclick","hostDeleteDir("+serverid+", "+dirid+");");
	// Add element to the page
	document.getElementById("server_"+serverid+"_config").append(newDirEntryClone);
}

//Add new Host
function addNewHost(id) {
	var lastid = parseInt(id)-1;
	var lastKnownHostElement = document.getElementById("host_item_"+lastid);
	var newHostEntryClone = lastKnownHostElement.cloneNode(true);
	// Change the ids in the element to be add
	newHostEntryClone.id = "host_item_"+id;
	newHostEntryClone.getElementsByTagName("button")[0].setAttribute("data-bs-target","#collapse_"+id);
	newHostEntryClone.getElementsByTagName("button")[0].setAttribute("aria-controls","collapse_"+id);
	var newHostName = document.getElementById("modal_add_host").getElementsByTagName("input")[0].value;
	newHostEntryClone.getElementsByTagName("button")[0].innerHTML = "<b>"+newHostName+"</b>";
	newHostEntryClone.getElementsByTagName("button")[1].id = "server_"+id+"_dir_0_del"
	newHostEntryClone.getElementsByTagName("button")[1].setAttribute("onclick","hostDeleteDir("+id+", 0);");
	newHostEntryClone.getElementsByTagName("button")[2].setAttribute("onclick","hostAddDir("+id+",1);");
	newHostEntryClone.getElementsByTagName("button")[3].setAttribute("onclick","hostDelete("+id+");");
	newHostEntryClone.getElementsByTagName("input")[0].id = "server_"+id+"_dir_0_dir";
	newHostEntryClone.getElementsByTagName("input")[0].name = "server_"+id+"_dir_0_dir";
	newHostEntryClone.getElementsByTagName("input")[0].value = "";
	newHostEntryClone.getElementsByTagName("input")[1].id = "server_"+id+"_dir_0_args";
	newHostEntryClone.getElementsByTagName("input")[1].name = "server_"+id+"_dir_0_args";
	newHostEntryClone.getElementsByTagName("input")[1].value = "";
	newHostEntryClone.getElementsByTagName("div")[0].id = "collapse_"+id;
	newHostEntryClone.getElementsByTagName("div")[0].setAttribute("aria-labelledby","server_"+id+"_name");
	newHostEntryClone.getElementsByTagName("div")[2].id = "server_"+id+"_config";
	newHostEntryClone.getElementsByTagName("div")[3].id = "server_"+id+"_dir_0_entryGroup";
	// Increase the id for the next add
	var nextid = parseInt(id)+1;
	document.getElementById("modal_add_host_btn").setAttribute("onclick","addNewHost("+nextid+");");
	// Reset the input in modal
	document.getElementById("modal_add_host").getElementsByTagName("input")[0].value = "";
	// Add element to the page
	document.getElementById("accordion").append(newHostEntryClone);
	//console.log(newHostEntryClone.outerHTML);
}

//Add line to backup_script 
function addBkpScript(id) {
	
	var nextid = parseInt(id)+1;
	var backupScriptElement = document.getElementById("add_bkp_script");
	var backupScriptClone = backupScriptElement.cloneNode(true);
	// Change the ids in the element to be add
	backupScriptClone.classList.remove('d-none');
	backupScriptClone.id = "bkp_script_"+id+"_info";
	backupScriptClone.getElementsByTagName("input")[0].name ="bkp_script_"+id+"_script";
	backupScriptClone.getElementsByTagName("input")[1].name ="bkp_script_"+id+"_target";
	backupScriptClone.getElementsByTagName("button")[0].setAttribute("onclick","delBkpScript("+id+");");
	//
	document.getElementById("add_bkp_script_btn").setAttribute("onclick","addBkpScript("+nextid+");");
	
	// Add element to the page
	document.getElementById("bkp_scripts").append(backupScriptClone);
}

//Delete line from backup_script 
function delBkpScript(id) {
	document.getElementById("bkp_script_"+id+"_info").remove();
}

// Add line to retain
function addRetain(id) {
	var nextid = parseInt(id)+1;
	var retainElement = document.getElementById("retain_to_add");
	var retainClone = retainElement.cloneNode(true);
	// Change the ids in the element to be add
	retainClone.classList.remove('d-none');
	retainClone.id = "retainNumber_"+id;
	retainClone.getElementsByTagName("input")[0].name ="retain_"+id+"_name";
	retainClone.getElementsByTagName("input")[1].name ="retain_"+id+"_count";
	retainClone.getElementsByTagName("input")[1].value = 1;
	retainClone.getElementsByTagName("button")[0].setAttribute("onclick","delRetain('"+id+"');");
	//
	document.getElementById("retain_add_btn").setAttribute("onclick","addRetain('"+nextid+"');");
	// Add element to the page
	document.getElementById("retains").append(retainClone);
}

// Delete line from retain
function delRetain(id) {
	document.getElementById("retainNumber_"+id).remove();
}

// Add Crontab, select funktionality
function changeCronSelect(id) {
	document.getElementById(id+'_text').value = document.getElementById(id).value;
}

// Add Crontab
function addCronjob(id) {
	// Gather all infos about the cron and build the cron line
	var newcronjob  = document.getElementById('cron_minute_text').value;
		newcronjob += " " + document.getElementById('cron_hour_text').value;
		newcronjob += " " + document.getElementById('cron_day_text').value;
		newcronjob += " " + document.getElementById('cron_month_text').value;
		newcronjob += " " + document.getElementById('cron_week_text').value;
		newcronjob += " " + document.getElementById('cron_user').value;
		newcronjob += " " + document.getElementById('cron_command_text').value;
	// Get the hidden element and create a copy of it
	var cronElement = document.getElementById("cron_new");
	var cronClone = cronElement.cloneNode(true);
	// Change the element to be add
	cronClone.classList.remove('d-none');
	cronClone.id = "cron_"+id;
	cronClone.getElementsByTagName("input")[0].name="cronjob_"+id;
	cronClone.getElementsByTagName("input")[0].id="cronjob_"+id
	cronClone.getElementsByTagName("input")[0].value=newcronjob;
	cronClone.getElementsByTagName("button")[0].setAttribute("onclick","deleteCronjob("+id+");");
	cronClone.getElementsByTagName("input")[1].id="cronCheck_"+id;
	cronClone.getElementsByTagName("input")[1].setAttribute("onclick","disbaleCronjob(this.id,"+id+");");
	// Increase the id for the next run
	var nextid = parseInt(id)+1;
	document.getElementById("addNextCronjob_btn").setAttribute("onclick","addCronjob("+nextid+");");
	document.getElementById("newcronid").value = nextid;
	// Add element to the page
	document.getElementById("cronjobs").append(cronClone);
	// Empty the modal
	document.getElementById("cron_command_text").value = "";
	document.getElementById("cron_minute_text").value = "";
	document.getElementById("cron_hour_text").value = "";
	document.getElementById("cron_day_text").value = "";
	document.getElementById("cron_month_text").value = "";
	document.getElementById("cron_week_text").value = "";
}

// Delete Crontab
function deleteCronjob(id) {
	document.getElementById("cron_"+id).remove();
}

// Enable/Disable Crontab
function disbaleCronjob(id) {
	var cronvalue = document.getElementById('cronjob_'+id).value;
	if (document.getElementById("cronCheck_"+id).checked) {
		document.getElementById('cronjob_'+id).value = "#"+cronvalue;
		document.getElementById('cronjob_'+id).disabled = true;
	} else {
		document.getElementById('cronjob_'+id).value = cronvalue.slice(1);
		document.getElementById('cronjob_'+id).disabled = false;
	}
}

// Enable/Disable Crontab email
function disableCronEmail() {
	if (document.getElementById("cron_email_checkbox").checked) {
		document.getElementById('cron_email').readOnly = true;
	} else {
		document.getElementById('cron_email').readOnly = false;
	}
}
