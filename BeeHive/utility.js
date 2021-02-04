async function select_waf() {
    // Waf Selector
    let waf = document.getElementById('waf-select').value;
    // Grab the waf-results div to start placing the file return in it. 
    let waf_results = document.getElementById('waf-results');      

    // Pull in the json file to be parsed. 
    let waflist = await eel.waf_select(waf)();

    // Call into Python so we can access the file system
    
    // Build the form used to parse the json file. 
    let wafForm = "<form onsubmit=\"select_option(); return false;\" >\n";
    
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
    wafForm += "<div id=\"option-results\">---</div>\n";

    // Put it all together.
    waf_results.innerHTML =  wafForm;
}

async function select_option() {
    // Grab the options-results div to display list of options.
    let optionForm = document.getElementById('option-results');

    // Call into Python so we can access the file system

    // Build the form used to parse the json file.
    let optForm = "<form onsubmit=\"pick_results(); return false;\" >\n";

    // Building the dropdown selector input.
    optForm += "<select name=\"options\" id=\"select-options\">\n";

    // Looping through the json file to get the first options.

    optForm += '<option value= "dir">Directory Results</option>\n';
    optForm += '<option value= "spid">Spider Results</option>\n';
    optForm += '<option value= "osint">Osint Results</option>\n';
    optForm += '<option value= "vuln">General Vulnerability Results</option>\n';

    // Close out the Select dropdown.
    optForm += "</select>\n";

    // Make a submit button for the form.
    optForm += "<button type=\"submit\">Select Results</button>\n";

    // Close out the form.
    optForm += "</form>\n";

    // Build a placeholder div for the URL search results.
    optForm += "<div id=\"pick-results\">---</div>\n";

    // Put it all together.
    optionForm.innerHTML =  optForm;
}



async function pick_results() {
    // Get the URL Value.
    let waf = document.getElementById('waf-select').value;
    let opt = document.getElementById('select-options').value;
    let url = document.getElementById('url-select').value;

    // Get the URL container div. 
    let pick_div = document.getElementById('pick-results');      
    
    let pick_results = ""
    // Pull Back the URL information from the JSON. 
    let filename = await eel.url_select(waf, opt)();

    // Loop through and parse the directory results. 
    //for (let i in filename) 
    //{
        pick_results += '<iframe class=\"show\" src=\"' + filename[url] + '\" align=\"right\" ></iframe>'
    //}

    // Put the results in the container div. 
    pick_div.innerHTML =  pick_results;
}
      
