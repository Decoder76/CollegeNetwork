# College Network

A Rails 8 application for college profiles, posts, user connections, and private conversations.

## Requirements

- Ruby 3.4.1
- PostgreSQL
- Bundler 2.6.6 (Bundler installs the lockfile version if needed)

## Run locally

```sh
bundle install
bin/rails db:prepare
bin/rails server
```

Open `http://localhost:3000` and create an account. Configure PostgreSQL access through your local PostgreSQL role or `DATABASE_URL`.

## Features and permissions

- Signed-in users can browse posts and profiles. Users can create, edit, and delete only their own posts and profiles.
- Connection requests must be accepted before users become network connections. Removing a connection does not change conversation membership.
- Conversations are visible only to active participants. Participants can send messages; only the author can edit or delete their messages.
- A participant can invite someone already in their network. The conversation creator must approve invitations from other participants, and the invitee must then accept. Invitations expose no conversation messages before acceptance.
- A participant's request to leave is approved or declined by the person who invited them. Approval removes that user from that conversation only; it does not remove their network connections.

## Tests

```sh
bin/rails test
bin/rails test:system
```
