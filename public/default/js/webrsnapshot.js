// JS to get tabs working 
$(function() { $( "#tabs" ).tabs(); });

// JS to get menu working
$(function() { $( "#menu" ).menu(); }); 

// JS to get accordion(Servers) working
$(function() { 
  $( "#accordion" ).accordion({
    collapsible: true,
      heightStyle: "content",
  });
});

// JS to get Tooltips working
$(function () { 
  $(document).tooltip({ 
    track: true,
    tooltipClass:'tooltip', 
    content: function () { 
      return $(this).prop('title'); 
    } 
  }); 
});

// Delete field from include
function delExIn(id) {
  $("#"+id+"_info").remove();
  $("#"+id+"_label").remove();
  $("#"+id).remove();
}

//Add field to include Config
function addInclude(buttonid, count) {
  var next = parseInt(count)+1;
  document.getElementById(buttonid).name         = next;
  document.getElementById("include_count").value = next;
  $("#include").append('<div class="infoicon" id="include_' + count +'_info">' +
      '<img src="default/img/info.png" ' + 
        'title="This gets passed directly to rsync using the <b>--include</b> directive.' +
          'This parameter can be specified as many times as needed, with one pattern defined' +
          'per line." />'+
    '</div>'+
    '<div class="configlabel" id="include_' + count + '_label"><LABEL>include</LABEL></div>' +
    '<div id="include_' + count + '">' +
      '<INPUT type="button" value="Delete" onclick="delExIn(\'include_' + count +'\');"> ' + 
      '<INPUT type="text" name="include_' + count + '" value="" />' +
    '</div>');
}

// Add field to exclude Config
function addExclude(buttonid, count) {
  var next = parseInt(count)+1;
  document.getElementById(buttonid).name         = next;
  document.getElementById("exclude_count").value = next;
    $("#exclude").append('<div class="infoicon" id="exclude_'+ count +'_info">' +
        '<img src="default/img/info.png" '+
          'title="This gets passed directly to rsync using the <b>--exclude</b> directive.' + 
          'This parameter can be specified as many times as needed, with one pattern defined' + 
          'per line." />' +
      '</div>' +	
      '<div class="configlabel" id="exclude_' + count + '_label"><LABEL>exclude</LABEL></div>' +
      '<div id="exclude_'+ count + '">' +
        '<INPUT type="button" value="Delete" onclick="delExIn(\'exclude_' + count + '\');"/> ' +
        '<INPUT type="text" name="exclude_' + count +'" value="" />' +
      '</div>');
}

// Delete Server Config
function serverDelete(id) {
  $( "#server_"+id+"_name" ).remove();
  $( "#server_"+id+"_config" ).remove();
}

// And Delete specific directory from backuped server 
function srvDelDir(serverid, dirid) {
  $( "#server_"+serverid+"_dir_"+dirid+"_del" ).remove();
  $( "#server_"+serverid+"_dir_"+dirid+"_dir" ).remove();
  $( "#server_"+serverid+"_dir_"+dirid+"_args" ).remove();
}

//Add another directory for backup on specific server
function srvAddDir(buttonid, dir_id, serverid) {
  // alert("Servername: " + name + "\nServerid: " + serverid);
  var next = parseInt(dir_id)+1;
  document.getElementById(buttonid).name = next;
  document.getElementById("server_" + serverid + "_dircount").value = next;
  $("#server_" + serverid + "_dirs").append('<div id="server_' + serverid + '_dir_' + dir_id + '">' +
      '<INPUT type="button" value="Delete" id="server_' + serverid + '_dir_' + dir_id + '_del" ' +
              'onclick="srvDelDir(' + serverid + ', ' + dir_id + ')" /> ' + 
      '<INPUT type="text" id="server_' + serverid + '_dir_' + dir_id + '_dir" ' +
              'name="server_' + serverid + '_dir_' + dir_id + '_dir" value="" /> ' +
      '<INPUT type="text" id="server_' + serverid + '_dir_' + dir_id + '_args" ' +
              'name="server_' + serverid + '_dir_' + dir_id + '_dir" value="" /><br/></div>');
}

// Add new Server 
function srvAdd(buttonid, serverid) {
  // Ask for the server label and server IP of FQDN
  var serverlabel = prompt("Please type the server label?\n\n" +
      "The server label will be used for better desribing the server.\n" +
      "It can be any name you can assign to the given server.\n" +
      "Using spaces is possible, but not desired.\n\n" +
      "Examples: localhost, john-s-server, 192.168.1.1\n\t\t  example.com, server.example.com");
  if (serverlabel) { var serverip = prompt("Please type the server IP or QFDN?\n\n" +
      "This should be the server ip or the server FQDN (Fully Qualified Domain Name)\n" +
      "Over this domain name the server should be reachable in the internet.\n " +
      "If you want to use different access method than root@server-ip you can\n" + 
      "change this after adding the server. Other possible connections can be:\n" +
      "user@example.com, rsync://example.com\n\n" +
      "Examples: localhost, 127.0.0.1, 192.168.10.34, 10.0.45.154\n" +
      "\t\t  example.com, server.example.com" ); }

  // Remove localhost or 127.0.0.1 from the name and access the local machine direct
  if (serverip == "localhost" || serverip == "127.0.0.1")
  {
    var serverip_new = "";
  }
  else
  {
    var serverip_new = "root@" + serverip + ":";
  }
  // Set the button with the ID for the next Server and type hidden for the save function 
  var next = parseInt(serverid)+1;
  document.getElementById(buttonid).name         = next;
  document.getElementById("servers_count").value = next;
  // And add the Server configuration
  if (serverlabel && serverip) {	
    $("#accordion").append('<h3 id="server_' + serverid + '_name">' +
          'Server: <b>' + serverlabel + '</b>' +
        '<INPUT type="button" value="Delete" onclick="serverDelete(' + serverid + ')" />' +
      '</h3>' +
      '<div id="server_' + serverid + '_config">' +
        '<INPUT type="hidden" id="server_' + serverid + '_label" name="' + serverlabel + '"/>' +
        '<div id="server_' + serverid + '_dirs">' +
          '<div id="server_' + serverid + '_dir_0">' +
            '<INPUT type="button" value="Delete" id="server_' + serverid + '_dir_0_del" ' +
                    'onclick="srvDelDir(' + serverid + ', 0)" /> ' +
            '<INPUT type="text" id="server_' + serverid + '_dir_0_dir" ' +
                    'name="server_' + serverid + '_dir_0_dir" value="' + serverip_new + '/etc/" /> ' +
            '<INPUT type="text" id="server_' + serverid + '_dir_0_args" ' +
                    'name="server_' + serverid + '_dir_0_args" value="" /><br/>' +
          '</div>' +
        '</div>' +
        '<INPUT type="button" value="Add" id="srvAddDir_' + serverid + '" ' +
                'name="0" onclick="srvAddDir(this.id, this.name, \'' + serverid + '\', \'1\');" />' +
      '</div>');
    $( "#accordion" ).accordion( "refresh" );
  } // End of if
}
