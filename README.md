This directory will act as a workspace for a white-box test comparing two programs.

1. The baseline program is called `http`, and it is the official Python implementation of HTTPie.
2. The other program is called `spie`, aka "SwiftPie", and is a work-in-progress clone of HTTPie implemented in Swift.

The plan is to examine the `--help` output of HTTPie and then create a checklist every option and behavior, storing that in `checklist.md` - each item in that list will be assigned a "slug" identifier string to be used as an anchor to refer to the feature or behavior. The slug is a valid portion of a filename that can be used to refer to the feature easily later.

Once approved, a subagent will be spawned for each and every feature. A plan will be created for testing each feature, and written to features/{slug}.md, then a new subagent can be spawned to execute that plan, which will update the feature file with any notes about the results of testing. If any issues are found, they should be logged in the corresponding feature file. Additionally, all issues will be written to issues/{issue-id}-{feature-slug}.md

Issue IDs can be generated using: `python3 -c 'import random; print(random.randint(10000, 99999))'`

Any deviation between `http` and `spie` is an issue. Issues should explain what
was tested, what was expected, what actually happened, and why it is an issue.

During testing, the root agent will run the httpbin server in the background. Sub agents are only permitted to test the client implementations by using them to make requests against this server. No other network endpoints may be accessed by any means. This backend is documented with the swagger spec at ./context/httpbin-swagger.json

If something cannot be tested for some reason, that itself is an issue and should be logged.

spie and http will both be on PATH for you. Before beginning anything, verify that is true.
