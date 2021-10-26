function getUrlFragments(){
    var hashString = window.location.hash.substring(1);
    var fragmentStrings = hashString.split("&");
    var fragments = {};
    fragmentStrings.forEach(str => {
        strs = str.split("=");
        fragments[strs[0]]= strs[1];
    });
    return fragments;
}

function getAccessToken(){
    var fragments = getUrlFragments();
    var accessToken = fragments["access_token"];
    console.log(accessToken)
    return accessToken
}




