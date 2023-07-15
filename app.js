AWS.config.region = 'us-west-2'; 
AWS.config.credentials = new AWS.CognitoIdentityCredentials({
    IdentityPoolId: 'us-west-2:12345678-1234-1234-1234-123456789012',
});
var poolData = {
    UserPoolId: 'us-west-2_uXboG5pAb',
    ClientId: '25ddkmj4v6hfsfvruhpfi7n4hv' 
};
var userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);

function login() {
    var username = document.getElementById('username').value;
    var password = document.getElementById('password').value;

    var authenticationData = {
        Username: username,
        Password: password
    };
    var authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails(authenticationData);

    var userData = {
        Username: username,
        Pool: userPool
    };
    var cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);

    cognitoUser.authenticateUser(authenticationDetails, {
        onSuccess: function(result) {
            var accessToken = result.getAccessToken().getJwtToken();
            console.log('Access Token: ' + accessToken);
            fetch('your-api-endpoint', {
                method: 'GET',
                headers: {
                    'Authorization': 'Bearer ' + accessToken
                }
            }).then(response => {
                console.log(response);
            }).catch(error => {
                console.error(error);
            });
        },
        onFailure: function(err) {
            console.error(err);
        }
    });
}
