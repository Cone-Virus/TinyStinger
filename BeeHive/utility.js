async function select_waf() {
    // Waf Selector
    let waf = document.getElementById('waf-select').value;
    // Grab the waf-results div to start placing the file return in it. 
    let waf_results = document.getElementById('waf-results');      

    // Pull in the json file to be parsed. 
    let waflist = await eel.waf_select(waf)();

    // Call into Python so we can access the file system
    
    // Build the form used to parse the json file. 
    let wafForm = "<form onsubmit=\"pick_url(); return false;\" >\n";
    
    // Building the dropdown selector input. 
    wafForm += "<select name=\"URL\" id=\"url-select\">\n";
    
    // Looping through the json file to get the first options. 
    for (let i in waflist) {
        wafForm += '<option value= \"' + i + '\">' + waflist[i] + '</option>\n';
    }

    // Close out the Select dropdown.
    wafForm += "</select>\n";

    // Make a submit button for the form. 
    wafForm += "<button type=\"submit\">Select URL</button>\n";

    // Close out the form. 
    wafForm += "</form>\n";

    // Build a placeholder div for the URL search results. 
    wafForm += "<div id=\"url-result\">---</div>\n";

    // Put it all together.
    waf_results.innerHTML =  wafForm;
}


async function pick_url() {
    // Get the URL Value.
    let waf = document.getElementById('waf-select').value;
    let url = document.getElementById('url-select').value;

    // Get the URL container div. 
    let url_div = document.getElementById('url-result');      
    
    let url_results = ""
    // Pull Back the URL information from the JSON. 
    let filename = await eel.url_select(waf)();

    // Loop through and parse the directory results. 
    //for (let i in filename) 
    //{
        url_results += '<p><iframe src=\"' + filename[url] + '\" frameborder=\"0\" height=\"400\" width=\"95%\"></iframe></p>'
    //}

    // Put the results in the container div. 
    url_div.innerHTML =  url_results;
}
