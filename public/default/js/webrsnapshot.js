// Config: Delete field from include
function delInclExclEntry(id) {
    document.getElementById(id).remove();
}

//Add field to include config
function addIncludeEntry(id) {
    // Clone the element
    var includeEntryElement = document.getElementById("include-");
    var includeEntryClone = includeEntryElement.cloneNode(true);
    // Change the ids in the element to be add
    includeEntryClone.classList.remove('d-none');
    includeEntryClone.id = "include-"+id;
    includeEntryClone.getElementsByTagName("input")[0].name = "include-"+id;
    includeEntryClone.getElementsByTagName("button").include_del.setAttribute("onclick","delInclExclEntry('include-" + id + "');");
    includeEntryClone.getElementsByTagName("button").include_del.disabled = false;
    // Create the next id
    var next_id = parseInt(id)+1;
    document.getElementById("add_include_btn").setAttribute("onclick","addIncludeEntry('"+next_id+"');");
    // Add element to the page
    document.getElementById("include").append(includeEntryClone);
}

//Add field to exclude config
function addExcludeEntry(id) {
    // Clone the element
    var excludeEntryElement = document.getElementById("exclude-");
    var excludeEntryClone = excludeEntryElement.cloneNode(true);
    // Change the ids in the element to be add
    excludeEntryClone.classList.remove('d-none');
    excludeEntryClone.id = "exclude-"+id;
    excludeEntryClone.getElementsByTagName("input")[0].name = "exclude-"+id;
    excludeEntryClone.getElementsByTagName("button").exclude_del.setAttribute("onclick","delInclExclEntry('exclude-" + id + "');");
    excludeEntryClone.getElementsByTagName("button").exclude_del.disabled = false;
    // Create the next id
    var next_id = parseInt(id)+1;
    document.getElementById("add_exclude_btn").setAttribute("onclick","addExcludeEntry('"+next_id+"');");
    // Add element to the page
    document.getElementById("exclude").append(excludeEntryClone);
}

// Delete Host Config
function hostDelete(hostname) {
    document.getElementById("hostname_"+hostname).remove();
}

// Delete specific directory from backuped host
function hostDeleteDir(hostname, dirid) {
    document.getElementById("hostname_"+hostname+"_sourcegroup_"+dirid).remove();
}

//Add another directory for backup on specific host
function hostAddDir(hostname, dirid) {
    // Clone the element
    var newDirEntryElement = document.getElementById("new_dir_entry");
    var newDirEntryClone = newDirEntryElement.cloneNode(true);
    // Change the ids in the element to be add
    newDirEntryClone.classList.remove('d-none');
    newDirEntryClone.id = "hostname_"+hostname+"_sourcegroup_"+dirid;
    newDirEntryClone.getElementsByTagName("input")[0].name = "hostname_"+hostname+"__source_"+dirid;
    newDirEntryClone.getElementsByTagName("input")[0].id = "hostname_"+hostname+"__source_"+dirid;
    newDirEntryClone.getElementsByTagName("input")[1].name = "hostname_"+hostname+"__args_"+dirid;
    newDirEntryClone.getElementsByTagName("input")[1].id = "hostname_"+hostname+"__args_"+dirid;
    newDirEntryClone.getElementsByTagName("button").hostdir_del.disabled = false;
    newDirEntryClone.getElementsByTagName("button").hostdir_del.setAttribute("onclick","hostDeleteDir('"+hostname+"', "+dirid+");");
    // Create dir count
    var nextid= parseInt(dirid)+1;
    document.getElementById("hostname_"+hostname+"_addsource_btn").setAttribute("onclick","hostAddDir('"+hostname+"',"+nextid+");");
    // Add element to the page
    document.getElementById("config_"+hostname).append(newDirEntryClone);
}

//Add new Host
function addNewHost(hostname) {
    var hostname = document.getElementById('new_hostname').value;
    var lastKnownHostElement = document.getElementById("host_item_new");
    var newHostEntryClone = lastKnownHostElement.cloneNode(true);
    // Change the ids in the element to be add
    newHostEntryClone.classList.remove("d-none");
    newHostEntryClone.getElementsByTagName("button")[0].setAttribute("data-bs-target","#collapse_"+hostname);
    newHostEntryClone.getElementsByTagName("button")[0].setAttribute("aria-controls","collapse_"+hostname);
    newHostEntryClone.getElementsByTagName("button")[0].innerHTML = "<b>"+hostname+"</b>";
    newHostEntryClone.getElementsByTagName("button")[1].setAttribute("onclick","hostDeleteDir('"+hostname+"', 0);");
    newHostEntryClone.getElementsByTagName("button")[2].setAttribute("onclick","hostAddDir('"+hostname+"',1);");
    newHostEntryClone.getElementsByTagName("button")[2].disabled = true;
    newHostEntryClone.getElementsByTagName("button")[3].setAttribute("onclick","hostDelete('"+hostname+"');");
    newHostEntryClone.getElementsByTagName("input")[0].id = "hostname_"+hostname+"__source_0";
    newHostEntryClone.getElementsByTagName("input")[0].name = "hostname_"+hostname+"__source_0";
    newHostEntryClone.getElementsByTagName("input")[0].value = "/etc/";
    newHostEntryClone.getElementsByTagName("input")[1].id = "hostname_"+hostname+"__args_0";
    newHostEntryClone.getElementsByTagName("input")[1].name = "hostname_"+hostname+"__args_0";
    newHostEntryClone.getElementsByTagName("input")[1].value = "";
    newHostEntryClone.getElementsByTagName("div")[0].id = "collapse_"+hostname;	 
    newHostEntryClone.getElementsByTagName("div")[2].id = "config_"+hostname;
    newHostEntryClone.getElementsByTagName("div")[3].id = "hostname_"+hostname+"_sourcegroup_0";
    // Increase the id for the next add
    document.getElementById("modal_add_host_btn").setAttribute("onclick","addNewHost();");
    // Reset the input in modal
    document.getElementById("modal_add_host").getElementsByTagName("input")[0].value = "";
    // Add element to the page
    document.getElementById("accordion").append(newHostEntryClone);
}

//Add line to backup_script 
function addBkpScript(id) {
    var backupScriptElement = document.getElementById("add_backup_script");
    var backupScriptClone = backupScriptElement.cloneNode(true);
    // Change the ids in the element to be add
    backupScriptClone.classList.remove('d-none');
    backupScriptClone.getElementsByTagName("input")[0].name ="backup_script_name_"+id;
    backupScriptClone.getElementsByTagName("input")[1].name ="backup_script_target_"+id;
    backupScriptClone.getElementsByTagName("button")[0].setAttribute("onclick","delBkpScript("+id+");");
    // Increase the id for the next add
    var nextid = parseInt(id)+1;
    document.getElementById("add_backup_script_btn").setAttribute("onclick","addBkpScript("+nextid+");");
    
    // Add element to the page
    document.getElementById("backup_script").append(backupScriptClone);
}

//Delete line from backup_script 
function delBkpScript(id) {
    document.getElementById("backup_script_"+id).remove();
}

// Add line to retain
function addRetain(id) {
    var retainElement = document.getElementById("retain_to_add");
    var retainClone = retainElement.cloneNode(true);
    // Change the ids in the element to be add
    retainClone.classList.remove('d-none');
    retainClone.id = "retain_"+id;
    retainClone.getElementsByTagName("input")[0].name ="retainname_"+id;
    retainClone.getElementsByTagName("input")[1].name ="retaincount_"+id;
    retainClone.getElementsByTagName("input")[1].value = 1;
    retainClone.getElementsByTagName("button")[0].setAttribute("onclick","delRetain('"+id+"');");
    // Increase the id for the next add
    var nextid = parseInt(id)+1;
    document.getElementById("retain_add_btn").setAttribute("onclick","addRetain('"+nextid+"');");
    // Add element to the page
    document.getElementById("retains").append(retainClone);
}

// Delete line from retain
function delRetain(id) {
    document.getElementById("retain_"+id).remove();
}

// Add Crontab, select funktionality
function changeCronSelect(id) {
    document.getElementById(id+'_text').value = document.getElementById(id).value;
}

// Add Crontab
function addCronjob() {
    // Gather all infos about the cron and build the cron line
    var newcronjob  = document.getElementById('cron_minute_text').value;
        newcronjob += " " + document.getElementById('cron_hour_text').value;
        newcronjob += " " + document.getElementById('cron_day_text').value;
        newcronjob += " " + document.getElementById('cron_month_text').value;
        newcronjob += " " + document.getElementById('cron_week_text').value;
        newcronjob += " " + document.getElementById('cron_user').value;
        newcronjob += " " + document.getElementById('cron_command_text').value;

    // Define the rsnapshot config file and the cronjobs count
    var commandline      = document.getElementById('cron_command_text').value;
    var configname       = commandline.slice(commandline.indexOf('-c') + 3);
    var confignameRetain = configname.slice(configname.lastIndexOf('/')+1);
    var confignameShort  = confignameRetain.slice(0, confignameRetain.indexOf(' '));
    var searchString     = "cron_"+confignameShort;
    var cronjobsCount    = document.querySelectorAll('[id^="'+searchString+'"]').length
    var newCronjobID = confignameShort+"_"+cronjobsCount;

    // Get the hidden element and create a copy of it
    var cronElement = document.getElementById("cron_new");
    var cronClone   = cronElement.cloneNode(true);

    // Change the element to be add
    cronClone.classList.remove('d-none');
    cronClone.id = "cron_"+newCronjobID;
    cronClone.getElementsByTagName("input")[0].name="cronjob_"+newCronjobID;
    cronClone.getElementsByTagName("input")[0].id="cronjob_"+newCronjobID
    cronClone.getElementsByTagName("input")[0].value=newcronjob;
    cronClone.getElementsByTagName("button")[0].setAttribute("onclick","deleteCronjob('"+newCronjobID+"');");
    cronClone.getElementsByTagName("input")[1].id="cronCheck_"+newCronjobID;
    cronClone.getElementsByTagName("input")[1].setAttribute("onclick","disableCronjob('"+newCronjobID+"');");

    // Add element to the page and remove class hidden
    document.getElementById("cronjobs_"+confignameShort).classList.remove("d-none");
    document.getElementById("cronjobs_"+confignameShort).append(cronClone);

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
    var cronSearchString = "cron_"+id.slice(0,id.lastIndexOf('_')+1);
    var cronjobsCount    = document.querySelectorAll('[id^="'+cronSearchString+'"]').length
    document.getElementById("cron_"+id).remove();
    if(cronjobsCount == 1) {
        document.getElementById("cronjobs_"+id.slice(0,id.lastIndexOf('_'))).classList.add("d-none");
    }
}

// Enable/Disable Crontab
function disableCronjob(id) {
    if (document.getElementById('cronCheck_'+id).checked) {
        document.getElementById('cronjob_'+id).readOnly = true;
    } else {
        document.getElementById('cronjob_'+id).readOnly = false;
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

// Disable all cronjobs at once
function disbaleAllCronjobs() {
    var cronjobsInput 	 = document.querySelectorAll('[id^="cronjob_"]');
    var cronjobsCheckbox = document.querySelectorAll('[id^="cronCheck_"]');
    for(var i = 0; i < cronjobsInput.length; i++){
        cronjobsInput[i].readOnly = true;
    }
    for(var i = 0; i < cronjobsCheckbox.length; i++){
        cronjobsCheckbox[i].checked = true;
    }
}

// Add new backip_exec line
function addBackupExec(id) {
    var backupExecElement = document.getElementById("add_backup_exec");
    var backupExecClone = backupExecElement.cloneNode(true);
    // Change the ids in the element to be add
    backupExecClone.classList.remove('d-none');
    backupExecClone.id = "backup_exec_"+id;
    backupExecClone.getElementsByTagName("input")[0].name ="backup_exec_command_"+id;
    backupExecClone.getElementsByTagName("select")[0].name ="backup_exec_importance_"+id;
    backupExecClone.getElementsByTagName("select")[0].id ="backup_exec_importance_"+id;
    backupExecClone.getElementsByTagName("button")[0].setAttribute("onclick","delBackupExec("+id+");");
    // Increase the id for the next add
    var nextid = parseInt(id)+1;
    document.getElementById("add_backup_exec_btn").setAttribute("onclick","addBackupExec("+nextid+");");

    // Add element to the page
    document.getElementById("backup_exec").append(backupExecClone);
}

// Delete backup_exec entry
function delBackupExec(id) {
    document.getElementById("backup_exec_"+id).remove();
}

// Create new rsnapshot configuration file
function createNewRSFile() {
    var configsCount = document.getElementsByClassName("rs_filename").length;
    let f = document.getElementById("newconfigform");
    f.action = "/"+configsCount+"/newconfig";
    f.submit();
}

// Check the new rsnapshot file while typing
function checkRSFilename() {
    let x = document.getElementById("new_rs_filename");
    let b = document.getElementById("add_rsconf_btn");
    const rs_reserved_names = document.getElementsByClassName("rs_filename");
    var wrongvalue = 0;
    for (rsname of rs_reserved_names) {
        if(rsname.innerHTML === x.value) { wrongvalue = 1; }
    }
    if(wrongvalue) { 
        x.classList.add("wrong-input");
        b.disabled = true;
    } else { 
        x.classList.remove("wrong-input");
        b.disabled = false;
    }
    var fileExt = x.value.split('.').pop();
    var confExt = "conf";
    if(fileExt === confExt) { 
        console.log("Extentions are the same");
        b.disabled = false;
    } else {
        console.log("Extentions are not the same");
        b.disabled = true; 
    }
}