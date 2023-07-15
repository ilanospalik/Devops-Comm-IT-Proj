var AWS = require('aws-sdk');
var AmazonCognitoIdentity = require('amazon-cognito-identity-js');

AWS.config.region = 'eu-west-1'; 
AWS.config.credentials = new AWS.CognitoIdentityCredentials({
    IdentityPoolId: 'eu-west-1:62d020b6-bcdf-4448-a12d-f47cfa50f8c6',
});
var poolData = {
    UserPoolId: 'eu-west-1_N570GMlUf',
    ClientId: '4pcki2mor36gspo5j7oqukr60b' 
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
