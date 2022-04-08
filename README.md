# Actuarial Theory and Practice A - Aim High

_"Tell me and I forget. Teach me and I remember. Involve me and I learn" - Benjamin Franklin_

---

### Congrats on completing the [2022 SOA Research Challenge](https://www.soa.org/research/opportunities/2022-student-research-case-study-challenge/)!

This is written in markdown language. 
>
* Click [4001 link](https://classroom.github.com/a/ggiq0YzO) to accept your group assignment.
* Click [5100 link](https://classroom.github.com/a/uVytCqDv) to accept your group assignment 

#### Follow the [guide doc](Doc1.pdf) to submit your work. 
---
>Be creative! Feel free to link to embed your [data](player_data_salaries_2020.csv), [code](sample-data-clean.ipynb), [image](ACC.png) here

More information on GitHub Pages can be found [here](https://pages.github.com/)
![](Actuarial.gif)


Ojectives of Analysis
 
-It is beneficial for a nation's economy to have a successful international football team. 
-A machine learning model is implemented for team selection 
-In addition to the allocated budget, our proposal leverages alternate streams of non-government funding.
-Revenues will be gained through matchday, broadcasting, sponsorship, merchandising, and prize money. 
 -The direct and indirect economic impacts were considered by analysing cash flows, effect on GDP, impact on industries and constructing a 10-year implementation plan. 
-The proposal also considers quantifiable and qualitative risks, appropriate mitigation techniques and monitoring metrics. Limitations of the proposal are also included.

## Selecting Rarita's National Team

---

We define a simple metric to measure the performance:

Performance Score (p.score) = W + 0.5D
where  W = Win and;
	D = Draw

_Data is sourced from League Goalkeeping. League statistics are used as data quality is better than Tournament (38 games for all squads, less missing observations)_

To account for squads with multiple goalkeepers, the p.score is weighted by the proportion of minutes played for each GK. This gives:

p.score = ∑_(for all i)▒〖ω_i (W_i+0.5D_i)〗
 where ω_i  =  (Playing time Min of goalkeeper i)/(∑_(for all i)▒〖Playing time Min of goalkeeper i〗)  and;

i = number of goalkeepers in a squad

The p.score is then mapped to all players in that squad. All players in the same squad will have the same p.score

The team selection process uses a Support Vector Machine classification model. This Machine Learning model is trained on League players (excluding Raritan) and classify if players are ‘competitive’ based on squad results.

_We acknowledge that player selection will never be an exact science, and there are human elements that our quantitative model cannot account for (e.g. synergy, discipline etc.) Therefore, the coaching staff will apply their judgement in the selection of the final National roster from the ‘competitive’ player pool identified by our model._

![](teamselection.fig5.1.png)

![](teamselection.fig5.2.png)

* Likelihood of top 10 finish in FSA league within 5 years: 87.2%
* Likelihood of FSA championship within 10 years: 84.2%


See the players selected for the [Rarita National Team](Team%20selection.csv) here!

Explore the [code](teamselection.R) here!


## Assumptions for the Rarita's national team construction: 

---

#### -> the general numerial assumptions listed below 
<img width="490" alt="image" src="https://user-images.githubusercontent.com/102893474/162420816-e28a16d0-8641-4390-8a2c-bb8cc7556e35.png">
 
#### -> other key assumptions made for the entire process
<img width="613" alt="image" src="https://user-images.githubusercontent.com/102893474/162423669-6888672e-2ea5-4767-a23e-1f2adda83c8d.png">

---

## Risks and Mitigation Approaches

---

![](riskmap.fig10.png)

| Scenarios  | Assumptions |
| ------------- | ------------- |
| High inflation  | 100bps increase in projected inflation  |
| Bearish equity market  | -30% investment returns in projection years 4 and 9  |
| Subdued operating revenue growth | Annual growth from all revenue streams capped at 10% |

![](scenarios.fig11.png)

![](sensitivity.fig12.png)

---




