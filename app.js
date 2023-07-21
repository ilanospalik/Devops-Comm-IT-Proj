AWS.config.region = 'eu-west-2';
AWS.config.credentials = new AWS.CognitoIdentityCredentials({
    IdentityPoolId: 'eu-west-2:52220ee4-a296-40ef-b192-f3b89772eb6f',
});

const poolData = {
    UserPoolId: 'eu-west-2_Y4UQrvSCp',
    ClientId: '7lquekgu06k4ve6fjvj3u2ikv1'
};

const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);

document.getElementById('loginForm').addEventListener('submit', function (event) {
    event.preventDefault();

    const loginForm = document.getElementById('loginForm');
    loginForm.classList.add('hidden');
    const loader = document.getElementById('loader');
    loader.classList.remove('hidden');
    const signUp = document.getElementById('signUpButton');
    signUp.classList.add('hidden');
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    const message = document.getElementById('message');

    const authenticationData = {
        Username: username,
        Password: password
    };

    const authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails(authenticationData);

    const userData = {
        Username: username,
        Pool: userPool
    };

    const cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);

    cognitoUser.authenticateUser(authenticationDetails, {
        onSuccess: function (result) {
            const accessToken = result.getAccessToken().getJwtToken();
            const idToken = result.getIdToken().getJwtToken();
            message.textContent = '';  // Clear the error message on successful login

            fetch('https://pct8v241xl.execute-api.eu-west-2.amazonaws.com/Dev/root', {
                method: 'GET',
                headers: {
                    'Authorization': 'Bearer ' + idToken
                }
            }).then(response => {
                if (!response.ok) {
                    message.textContent = 'Network response was not ok';
                }
                return response.json();
            }).then(data => {
                document.getElementById('loginForm').style.display = 'none';
                document.getElementById('signUpButton').style.display = 'none';
                loader.classList.add('hidden');
                const userDetails = document.getElementById('userDetails');
                userDetails.classList.remove('hidden');
                userDetails.textContent = data;
            }).catch(error => {
                loader.classList.add('hidden');
                loginForm.classList.remove('hidden');
                message.textContent = 'There has been a problem with your fetch operation: ' + error.message;
            });
        },

        onFailure: function (err) {
            loginForm.classList.remove('hidden');
            signUp.classList.remove('hidden');
            loader.classList.add('hidden');
            message.textContent = err.message || JSON.stringify(err);
        },
    });

    document.getElementById('username').addEventListener('input', function () {
        message.textContent = '';
    });
    document.getElementById('password').addEventListener('input', function () {
        message.textContent = '';
    });
});

document.getElementById('signupForm').addEventListener('submit', function (event) {
    event.preventDefault();

    const username = document.getElementById('signupUsername').value;
    const password = document.getElementById('signupPassword').value;
    const email = document.getElementById('signupEmail').value;
    var userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);
    var attributeList = [];
    var dataEmail = {
        Name: 'email',
        Value: email,
    };

    var attributeEmail = new AmazonCognitoIdentity.CognitoUserAttribute(dataEmail);
    attributeList.push(attributeEmail);

    userPool.signUp(username, password, attributeList, null, function (err, result) {
        if (err) {
            message.textContent = err.message || JSON.stringify(err);
            return;
        }
        var cognitoUser = result.user;
        message.textContent = cognitoUser.getUsername() + ' Confirm Your Account In Your Email, Then log In!';
    });
    document.getElementById('signupUsername').addEventListener('input', function () {
        message.textContent = '';
    });
    document.getElementById('signupPassword').addEventListener('input', function () {
        message.textContent = '';
    });
    document.getElementById('signupEmail').addEventListener('input', function () {
        message.textContent = '';
    });
});

document.getElementById('signUpButton').addEventListener('click', function () {
    document.getElementById('signUpButton').style.display = 'none';
    document.getElementById('signupForm').style.display = 'block';
    document.getElementById('loginForm').style.display = 'none';
    document.getElementById('loginButton').style.display = 'block';
});

document.getElementById('loginButton').addEventListener('click', function () {
    document.getElementById('loginForm').style.display = 'block';
    document.getElementById('signupForm').style.display = 'none';
    document.getElementById('signUpButton').style.display = 'block';
    document.getElementById('loginButton').style.display = 'none';
});
