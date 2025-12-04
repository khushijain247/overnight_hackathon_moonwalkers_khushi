dealer = input("Enter dealer name: ")
phone = int(input("Enter dealer phone number: "))
number = int(input("Enter number of farmers under the dealer: "))
land = float(input("Enter hectares of land owned by the farmer: "))#70% of farmers have less than 1 hectare(2.47 acres) of land
fertiliser = int(input("Enter amount of fertilisers provided by the dealer in kg: "))#per hectare, usually around 100-150 kg
output = int(input("Enter percentage yield of crops produced: "))

def sol():
    score = 0
    reasons = []
    #1.Low yield with large land = suspicious
    if output < 50 and land > 1:
        score += 2
        reasons.append("Low crop yield despite large land area")
    #2.High fertiliser but low output = suspicious
    if fertiliser > 150 and output < 50:
        score += 2
        reasons.append("High fertiliser usage but low yield")
    #3.Very low yield = suspicious
    if output < 30:
        score += 1
        reasons.append("Very low yield percentage")
    #4.Too many farmers under one dealer = suspicious
    if number > 80:
        score += 1
        reasons.append("Unusually large number of farmers under one dealer")
    #5.Very little land but high fertiliser = suspicious
    if land < 1 and fertiliser > 120:
        score += 2
        reasons.append("High fertiliser for small farmland")
    #6.If everything is normal
    if score == 0:
        print("NOT A SCAM — The inputs look normal.")
        return

    #Final risk decision
    print("POSSIBLE SCAM DETECTED!")
    print("Reason:")
    for r in reasons:
        print("• " + r)

    if score >= 4:
        print("RISK LEVEL: HIGH - High chance of fraud/scam")
    elif score >= 2:
        print("RISK LEVEL: MEDIUM — Suspicious, needs monitoring")
    else:
        print("RISK LEVEL: LOW — Mild irregularities")
sol()
