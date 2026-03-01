extends Node

signal on_score_updated(score : int)
signal on_money_earned(money : int)

var stored_shipments : Array[Pickup]
var stored_scores : Array[int]
var money_earned_since_last_shipment : int
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
    QualityEnum.Property.BURNT,
    QualityEnum.Property.NUTTY
]

var shipped_qualities : Array[QualityEnum.Property]

func ship_item(pickup : Pickup):
    
    shipped_items += 1
    var item_score = calculate_shipped_score(pickup)
    money_earned_since_last_shipment += item_score * MONEY_MULTIPLIER
    if stored_shipments.size() < max_stored_shipments:
        stored_shipments.append(pickup)
        stored_scores.append(item_score)
        for quality in pickup.item_qualities:
            if !shipped_qualities.has(quality):
                shipped_qualities.append(quality)
        if stored_shipments.size() == max_stored_shipments:
            
            var disliked_qualities :Array[QualityEnum.Property]
            for quality in stored_shipments:
                if shipping_dislikes.has(quality) and !disliked_qualities.has(quality):
                    disliked_qualities.append(quality)
            
            
            
            var average_score = average_int_array(stored_scores)
            on_score_updated.emit(average_score)
            print("shipping bundle with score of " + str(average_score))
            var disliked_qualities_from_shipment : Array[QualityEnum.Property]
            
            for quality in shipping_dislikes:
                if shipped_qualities.has(quality):
                    disliked_qualities_from_shipment.append(quality)
            var liked_qualitied_from_shipment : Array[QualityEnum.Property]
            
            for quality in shipping_prefrences:
                if shipped_qualities.has(quality):
                    liked_qualitied_from_shipment.append(quality)
            on_money_earned.emit(money_earned_since_last_shipment)
            get_tree().get_first_node_in_group("ReportCard").show_report(money_earned_since_last_shipment,disliked_qualities_from_shipment,liked_qualitied_from_shipment)
            stored_shipments = []
            stored_scores = []
            money_earned_since_last_shipment = 0
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
    for prefrence in shipping_dislikes:
        if pickup.item_qualities.has(prefrence):
            score -= 1
            
    return maxi(score,0)

func average_int_array(arr: Array[int]) -> float:
    if arr.is_empty():
        return 0.0
    var sum := 0
    for n in arr:
        sum += n

    var average := float(sum) / arr.size()
    print(average) # 5.0
    return average
