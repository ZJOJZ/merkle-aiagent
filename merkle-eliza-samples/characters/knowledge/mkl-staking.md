# MKL Staking

Our ve (vote-escrowed) staking model encourages long-term commitment and active participation. Here’s how it works:

<figure><img src="https://miro.medium.com/v2/resize:fit:1260/1*BpV23OMyoazCEWsIU886Qg.png" alt="" height="394" width="700"><figcaption></figcaption></figure>

**MKL Tokens** — Primary transferable utility tokens within the ecosystem.

**preMKL Tokens**— Non-transferable, pre-TGE MKL tokens that will be converted 1:1 to MKL tokens upon the conclusion of the TGE sequence.

**esMKL Tokens** — Non-transferable reward tokens earned through various incentive programs or by holding veMKL tokens. esMKL tokens can be staked to obtain veMKL tokens or vested linearly over 90 days to convert them into MKL tokens.

**veMKL Tokens** — Non-transferable tokens obtained by staking MKL or esMKL tokens for a chosen lockup period (min: 2 weeks, max: 52 weeks). Core features of veMKL tokens are as follows.

* veMKL tokens entitle holders to a share of the protocol’s revenue, proportional to their share of the total veMKL issuance. veMKL tokens become eligible for revenue sharing in the following epoch (1 epoch = 1 week), with the actual revenue distribution occurring in the subsequent epoch.
* veMKL tokens will grant governance rights once the transition to a DAO-led structure is complete.
* veMKL tokens will gain additional features such as boosted referral rebates, exclusive benefits for trading seasons, and more.

Users receive veMKL tokens according to the following formula:

$$
veMKL = MKL \, Locked \times \frac{t}{t_{max}}
$$

* veMKL tokens decrease linearly every epoch as the due date approaches, but users can always extend their lock-up period during this time.
* For instance, if Alice stakes 100 MKL tokens with a 26 week lockup period, she will receive 50 veMKL tokens. In contrast, if Adam stakes 100 MKL tokens with a 52 week lockup period, he will receive 100 veMKL tokens. After 6 months, without any extension, Alice will have 0 veMKL tokens, while Adam will have 50 veMKL tokens remaining.

There will be additional features of veMKL such as boosted referral rebates, exclusive benefits in trading seasons, and more. We will provide detailed information as we develop them after the TGE sequence concludes.
