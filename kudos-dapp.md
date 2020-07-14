DAPP similar to Taco Slack extension

- props
- kudos

## User Stories

All Stories below faciliated via the DAPP:

`space` stats public or private?

V1:

- As an admin, I want to create a `space` with initial parameters, so that the community can participate.
  - tacos limit per player per refresh (ex daily)
- As admin, I want to be able to add 'player's to my space, so that they can participate.
- As admin, I want to be able to transfer management rights another player, so that I can pass on management responsibilities.
- As a player, I want to be able to `tip` other players, but not myself, so that I can show appreciation to others.
- As a player, I want to view the scoreboards of a `spaces` I am part of, so that I can track the stats.

V2:

- A `space` has a season (inital parameter: period or infinity) that reset the accumulated tacos of all players to zero (ex quarterly)
- As admin, I want to be able to modify the `space` parameters, so that they can better suit the community.
  - As the public, I can view the current parameters
- As admin, I want to be able to deactive (or delete) 'player's to my space, so that they can no longer participate.
- As the public, I want to be able to view the scoreboard of a `space`, so that I can checkout the DAPP.
- As a player, I want to view all scoreboards of all the `spaces` I am part of, so that I can track the stats.

V3:

- As admin, I want to be able to create rewards that players can trade their tacos in for, so that I can increase engagement.
- As a player, I want to be able to trade in my tacos for predefined rewards, so that I incentivized to participate.
- As the players, I want to be able to vote on proposed modification to the parameters, so that there is some oversight.
- As admin, I want to be able to deactive (or delete) a `space`, so that no one can participate.
- As admin, I want to be able to transfer management rights additional player(s), so that I can pass on management responsibilities to a list of users.

- And beyond... gamification:
  - level (relative or absolute)
  - badges
    - given, received, rewards claimed, joining anniversary => (streaks/frequency/absolute)
  - in-game rewards
    - additional proposal vote weight,

## Technical Challenges

- How track tacos?
  - internal point system
  - create fungible token, upon tipping `space` contract send token
    - can send contracts balance to an user? or must belong to user first?
  - query last `limit` indexed events? (emit event on tipping)
- How to mimic daily reset? CRON, not possible in Ethereum?
  - external CRON job trigger
  - storing the time of last five tacos given. Upon tiping, check the last/latest five timestamps greater than 24 hours.
    - use fix array of timestamps?
- How to upgrade contracts???

Events:
Events can only be handled by the frontside DApp code — not by another contract. The Log and its event data is not accessible from within contracts (not even from the contract that created them).
https://web3js.readthedocs.io/en/v2.0.0-alpha/web3-eth-contract.html?highlight=event#contract-events

## Glossary

- space/room
- tacos/currency/points
- rewards/prizes
- user types (admin, player, public)

## Contracts

### Factory

Contract Factory to allow teams to create their own tip `space`
An user can create a `space` and set tht parameters. This user becomes its manager.

### Space

Each `space` can create their own `taco` or whatever currency (ERC20?) or points system?

## FE

- React + MetaMask
- Extension + ???
