# Cover Interview Assignment

For your take home assignment, you'll be extending an encrypted data store for strings. Clients post string that they want stored encrypted to the `encrypted_strings` path and receive a token that they can use to later retrieve the string. Clients may also delete a previously decrypted string using their token. 

We need the add ability to change our Data Encrypting Keys when requested by a client (Key Rotation). When rotating keys, we need to take previously encrypted string and re-encrypt them using a new Data Encrypting Key. To do this, we will create 2 new API endpoints to be used for the rotation of our Data Encrypting Key.


```ruby 
POST /data_encrypting_keys/rotate
```

This endpoint should queue a background worker(s) (sidekiq) to rotate the keys and re-encrypt all stored strings. We don't want to allow clients to queue/perform multiple key rotations at the same time. If a job has alredy been queued or one is in progress, you should return the appropriate HTTP error code along with an error message in the json.

```ruby 
GET /data_encrypting_keys/rotate/status
```

This endpoints will return one of 3 strings in the `message` key of the json response:

1. `Key rotation has been queued` if there is a job in the Sidekiq queue but it hasn't started yet.
2.  `Key rotation is in progress` if the job is active.
3. `No key rotation queued or in progress` if there no queued or active key rotation job.


What the background job(s) should do

* Generate a new Data Encrypting Key
* Set the new key to be the primary one (primary: true), while making any old primary key(s) non-primary (primary: false)
* Re-encrypt all existing data with the new 
* Once all the data has been re-encrypted with the new Data Encrypting Key, any and all old, unused keys should be deleted


### Further Instructions


* Add the sidekiq gem to the project along with any configuration required
* Feel free to use third party libraries that you can justify
* You can change/refactor any existing code
* Add any missing tests that you think may be beneficial
* Add any validations you think may be beneficial
* Create any Service objects and lib modules that may be beneficial
* Rename any existing variables/methods to make the existing code easier to understand
* Fix any bugs you may find in the pre-existing code
* Add an integration test that loads a large number (1K+) of encrypted strings in to the database, queues a rotation job and then polls it until the job is complete

### What we're looking at

1. Can you read and understand an unfamiliar code base?
2. Can you convert written requirements into working code?
3. How, if at all, do you leverage third party libraries?
4. Is your code easy to understand and co-worker friendly?
5. Is your code sufficiently tested?
6. Can you clean up and fix bugs in existing code?

