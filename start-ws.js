username = process.env.LAB_NUMBER || "lab01"
password = process.env.LAB_PSWD || "redhat1!"
email = process.env.LAB_EMAIL || "${username}@redhat.com"
crw_url = process.env.LAB_URL || "https://codeready-crw.apps.foo.sandbox925.opentlc.com"

module.exports = {
    'Fire Up each CRW': function (browser) {
        browser
            .url(crw_url)
            .waitForElementVisible('body')
            .useXpath()
            .useCss()
            // Select keyclocak provider            
            .waitForElementVisible("a[title='Log in with keycloak']", 6000)
            .click("a[title='Log in with keycloak']")
            // Login with Keycloak OCP Creds
            .waitForElementVisible('input[name="username"]', 6000)
            .setValue('input[name="username"]', username)
            .setValue('input[name="password"]', password)
            .click('input[name="login"]')	
            .waitForElementVisible('body', 6000)
            .pause('10000')
            .end()
    }
};

