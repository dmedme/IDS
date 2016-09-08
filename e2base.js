/*
 * Common functions.
 *
 * Show/Hide toggle.
 */
function shoh(id) {
    if (document.getElementById(id)
     && document.getElementById(id).style
     && document.getElementById(id).style.display)
    {
        if (document.getElementById(id).style.display == 'none')
            document.getElementById(id).style.display = 'block';
        else
            document.getElementById(id).style.display = 'none';      
    }
    else
    {
        if (document.layers)
        {  
            if (document.id.display == 'none')
                document.id.display = 'block';
            else
                document.id.display = 'none';
        }
        else
        {
            try {
                if (document.all.id.style.visibility == 'hidden')
                    document.all.id.style.visibility = 'visible';
                else
                    document.all.id.style.visibility = 'hidden';
            }
            catch (e) {
                alert("Cannot find id=" + id + " error: " + e);
            }
        } 
    }
}
var message_text;
var branch = new Array();   /* Natmenu forms invoking each other */
var have_focusable = false;
/*
 * Render natmenu-style forms delivered as JSON. This will be called by each
 * page from the onLoad trigger. Typically the function is drawform().
 */
function render_json(forms_json) {
    var form_set = eval('(' + forms_json + ')');
    var d = document.getElementById('loadmarker');
    if (message_text != null)
        form_text = '<p style="color:red; background-color:white;"><b>' +
                message_text + '</b></p><hr/>'
    else
        form_text = "";

    for (var i = 0; i < form_set.length; i++) 
        branch[form_set[i].name] = i;
    for (i = 0; i < form_set.length; i++) 
    {
        form_text = form_text + '<FORM name="pathform' + i +
                    '" action="/" method=get id="pathform' + i +
                    '"><table id="pathtab' + i + '" style="display:'+
                    ((i == 0)? 'block' : 'none') +'">' +
'<tr><td width="25%"></td><td/></tr><tr><td/><td><b><u><a name="' +
                    form_set[i].name + '">' +  form_set[i].HEAD +
                    '</a></u></b></td></tr>';
        if (form_set[i].SEL == "NO")
            form_text = form_text + '<input name="name" type="hidden" value="' +
                         form_set[i].name +'">';
        if (form_set[i].PARENT != null && branch[form_set[i].PARENT] != null)
            form_text = form_text + '<tr><td><a href="#' + form_set[i].PARENT +
                        '"' + ' onClick="' + "shoh('pathtab" + i +
                        "');shoh('pathtab" + branch[form_set[i].PARENT] + "')" +
                        '">' + form_set[branch[form_set[i].PARENT]].HEAD +
                        '</a></td></tr>';
        sub_flag = 0;
        for (j = 0; j < form_set[i].SCROLL.length; j++)
        {
            if (form_set[i].SEL == "NO")
            {
                form_text = form_text + '<tr><td>' +
                            form_set[i].SCROLL[j].LABEL +
                     '&nbsp;&nbsp;</td><td><input type=text size=40 name="p' +
                      j + '"' +
                      ((have_focusable == false) ? ' id="focus_here" ' : ' ' ) +
                     ' value="' + form_set[i].SCROLL[j].VALUE + '"></td></tr>';
                sub_flag = 1;
                have_focusable = true;
            }
            else
            if (form_set[i].SEL == "YES" && form_set[i].COMM == "YES")
            {
                form_text = form_text + '<tr><td>';
                if (form_set[i].SCROLL[j].VALUE != 'NULL:')
                {
                    form_text = form_text +
                        '<input type="submit" class="submit" name="pick" value="' +
                          form_set[i].SCROLL[j].VALUE + '"' +
                      (( have_focusable == false) ? ' id="focus_here" ' : ' ' );
                    have_focusable = true;
                    if (branch[form_set[i].SCROLL[j].VALUE] != null)
                        form_text = form_text + ' onClick="' +
                                    "shoh('pathtab" + i +"');shoh('pathtab" + 
                                     branch[form_set[i].SCROLL[j].VALUE] +
                                     "');return false" + '"';
                    form_text = form_text + '></td><td>';
                    sub_flag = 1;
                }
                else
                    form_text = form_text + '<td/>';
                form_text = form_text + form_set[i].SCROLL[j].LABEL +
                            '</td></tr>';
            }
            else
            if (form_set[i].SEL == "YES" && form_set[i].COMM == "NO")
            {
                form_text = form_text + '<tr><td><input type="hidden" name="p' +
                            j + '" value=""><input type="checkbox" value="Pick" onClick="pathform'+i+
                    '.p' +j + '.value=(pathform'+i+ '.p' +j +
                     '.value)?null:'+"'" + form_set[i].SCROLL[j].VALUE + "'" +
                     '"' + ((have_focusable == false) ? ' id="focus_here" ' :
                     ' ' ) + '</td><td>' + form_set[i].SCROLL[j].LABEL +
                     '</td></tr>';
                have_focusable = true;
                sub_flag = 1;
            }
        }
        if (sub_flag == 1)
        {
            if (form_set[i].SEL == "NO" || form_set[i].COMM == "NO")
                form_text = form_text +
                 '<tr><td><input type="submit" class="submit" name="Submit" value="Submit"' +
                    ((have_focusable == false) ? ' id="focus_here" ' : ' ' ) +
'></td></tr><tr><td><input type="Reset" class="submit" name="Reset" value="Reset"></td></tr>';
            have_focusable = true;
            form_text = form_text +
                  '<input type="hidden" name="ln_cnt" value="' + j + '">';
        }
        form_text = form_text + '</TABLE></FORM>';
    }
    d.innerHTML = form_text; 
    if (have_focusable)
        document.getElementById("focus_here").focus();
    return true;
}
/*
 * PUT handling
 */
var req=null;
function handleresp()
{
    return;
}
function put_file(fname, txt) {
/*
 * Mozilla and WebKit
 */
    if (window.XMLHttpRequest)
        req = new XMLHttpRequest();
    else
    if (window.ActiveXObject)
    {
/*
 * Internet Explorer (new and old)
 */
        try {
            req = new ActiveXObject("Msxml2.XMLHTTP");
        }
        catch (e) {
           try {
               req = new ActiveXObject("Microsoft.XMLHTTP");
           }
           catch (e) {}
        }
    } 
    req.open("PUT", fname, true);
    req.setRequestHeader("Content-type","application/octet-stream");
    req.setRequestHeader("Expect","100-Continue");
    req.onreadystatechange = handleresp;
    try
    {
        req.send(txt);
    }
    catch (e) {
        alert("PUT failed, Error: " + e)
    }
    return;
}
