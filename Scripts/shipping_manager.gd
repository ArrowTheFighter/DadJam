extends Node

signal on_score_updated(score : int)
signal on_money_earned(money : int)

var stored_shipments : Array[Pickup]
var stored_scores : Array[int]
var max_stored_shipments := 5

const MONEY_MULTIPLIER = 5

var shipped_items : int = 0
var shipping_prefrences = [
    QualityEnum.Property.ROASTED,
    QualityEnum.Property.SMOOTH,
    QualityEnum.Property.CHILLED,
    QualityEnum.Property.CREAMY,
    QualityEnum.Property.SWEET
]
var shipping_dislikes = [
    QualityEnum.Property.BURNT
]

func ship_item(pickup : Pickup):
    
    shipped_items += 1
    var item_score = calculate_shipped_score(pickup)
    on_money_earned.emit(item_score * MONEY_MULTIPLIER)
    if stored_shipments.size() < max_stored_shipments:
        stored_shipments.append(pickup)
        stored_scores.append(item_score)
        if stored_shipments.size() == max_stored_shipments:
            var average_score = average_int_array(stored_scores)
            on_score_updated.emit(average_score)
            print("shipping bundle with score of " + str(average_score))
            stored_shipments = []
            stored_scores = []
    print("shipping item with score of " + str(item_score))
    pass


func calculate_shipped_score(pickup : Pickup) -> int:
    var score = 1
    if pickup.item_qualities.has(QualityEnum.Property.BOXED):
        score += 3
    for quality in pickup.item_qualities:
        print(QualityEnum.Property.keys()[quality])
    for prefrence in shipping_prefrences:
        if pickup.item_qualities.has(prefrence):
            score += 1
            
    return score

func average_int_array(arr: Array[int]) -> float:
    if arr.is_empty():
        return 0.0
    var sum := 0
    for n in arr:
        sum += n

    var average := float(sum) / arr.size()
    print(average) # 5.0
    return average
