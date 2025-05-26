# Cross-chain Rebase Token

1. A protocol that allow user to deposit into a vault and in return, receiver rebase tokens that represents their underlying balance
2. Rebase token -> balanceOf is dynamic to show the changing balance with time
   1. Balance increases linearly with time
   2. mint token to our users every time they perform an action (minting, burning, transferring, or bridging)
3. Interest rate
   1. Individually set an interest rate of each user based on some global interest rate of the protocol at the time the user deposits into the vault
   2. This global interest rate can only decrease to incentivise / reward for early adopters
   3. Increase token adoption
