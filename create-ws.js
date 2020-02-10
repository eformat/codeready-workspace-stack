username = process.env.LAB_NUMBER || "lab01"
password = process.env.LAB_PSWD || "redhat1!"
email = process.env.LAB_EMAIL || "${username}@redhat.com"
crw_url = process.env.LAB_URL || "https://codeready-crw.apps.foo.sandbox925.opentlc.com/f?url=https://raw.githubusercontent.com/rht-labs/enablement-codereadyworkspaces/master/do500-devfile.yaml"

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
            //.click('button[type="submit"]')
            .click('input[name="login"]')
            // Approve perms for OCP land
            .waitForElementVisible('input[name="approve"]', 6000)
            .click('input[name="approve"]')
            // Fill in email for CRW nonsense
            .waitForElementVisible('input[name="email"]', 6000)
            .clearValue('input[name="firstName"]')
            .clearValue('input[name="lastName"]')
            .setValue('input[name="email"]', email)
            .setValue('input[name="firstName"]', username)
            .setValue('input[name="lastName"]', username)
            .click('input[value="Submit"]')
            .pause('10000')
            .waitForElementVisible('body', 6000)
            .end()
    }
};
