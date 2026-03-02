extends Node

const MONEY_MULTIPLIER = 15
signal on_score_updated(score : int)
signal on_money_earned(money : int)

## Planet 1
var stored_shipments : Array[Pickup]
var stored_scores : Array[int]
var money_earned_since_last_shipment : int
var max_stored_shipments := 5
var shipped_items : int = 0
var shipped_qualities : Array[QualityEnum.Property]


var shipping_prefrences = [
    QualityEnum.Property.ROASTED,
    QualityEnum.Property.SMOOTH,
    QualityEnum.Property.CHILLED,
    QualityEnum.Property.CREAMY,
    QualityEnum.Property.SWEET
]

var shipping_dislikes = [
    QualityEnum.Property.WET,
    QualityEnum.Property.JIGGLY,
    QualityEnum.Property.RADIOACTIVE,
    QualityEnum.Property.ORGANIC,
    QualityEnum.Property.EXPENSIVE,
    QualityEnum.Property.DECORATED,
]
## Planet 2
var p2_stored_shipments : Array[Pickup]
var p2_stored_scores : Array[int]
var p2_money_earned_since_last_shipment : int
var p2_shipped_items : int = 0
var p2_shipped_qualities : Array[QualityEnum.Property]


var p2_shipping_prefrences = [
    QualityEnum.Property.ROASTED,
    QualityEnum.Property.CHILLED,
    QualityEnum.Property.CREAMY,
    QualityEnum.Property.RADIOACTIVE,
    QualityEnum.Property.ORGANIC,
]

var p2_shipping_dislikes = [
    QualityEnum.Property.BURNT,
    QualityEnum.Property.NUTTY,
    QualityEnum.Property.SWEET,
    QualityEnum.Property.SMOOTH,
    QualityEnum.Property.WET,
    QualityEnum.Property.JIGGLY,
    QualityEnum.Property.EXPENSIVE,
    QualityEnum.Property.DECORATED,
]

##Planet 3
var p3_stored_shipments : Array[Pickup]
var p3_stored_scores : Array[int]
var p3_money_earned_since_last_shipment : int
var p3_shipped_items : int = 0
var p3_shipped_qualities : Array[QualityEnum.Property]


var p3_shipping_prefrences = [
    
    QualityEnum.Property.WET,
    QualityEnum.Property.JIGGLY,
    QualityEnum.Property.RADIOACTIVE,
    QualityEnum.Property.ORGANIC,
    QualityEnum.Property.EXPENSIVE,
    QualityEnum.Property.DECORATED,
]

var p3_shipping_dislikes = [
    QualityEnum.Property.BURNT,
    QualityEnum.Property.NUTTY,
    QualityEnum.Property.CHILLED,
    QualityEnum.Property.CREAMY,
]

signal planet_1_shipped(rating)
signal planet_2_shipped(rating)
signal planet_3_shipped(rating)


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
            var disliked_qualities_from_shipment : Array[QualityEnum.Property]
            for quality in shipping_dislikes:
                if shipped_qualities.has(quality):
                    disliked_qualities_from_shipment.append(quality)
            var liked_qualitied_from_shipment : Array[QualityEnum.Property]
            for quality in shipping_prefrences:
                if shipped_qualities.has(quality):
                    liked_qualitied_from_shipment.append(quality)
            on_money_earned.emit(money_earned_since_last_shipment)
            get_tree().get_first_node_in_group("ReportCard").show_report(
                money_earned_since_last_shipment,disliked_qualities_from_shipment,liked_qualitied_from_shipment,average_score,"Report; Planet Zorg"
                )
            stored_shipments = []
            stored_scores = []
            money_earned_since_last_shipment = 0
            planet_1_shipped.emit(average_score)
    pass
    
func ship_item_planet_2(pickup : Pickup):
    p2_shipped_items += 1
    var item_score = calculate_shipped_score(pickup)
    p2_money_earned_since_last_shipment += item_score * MONEY_MULTIPLIER
    if p2_stored_shipments.size() < max_stored_shipments:
        p2_stored_shipments.append(pickup)
        p2_stored_scores.append(item_score)
        for quality in pickup.item_qualities:
            if !p2_shipped_qualities.has(quality):
                p2_shipped_qualities.append(quality)
        if p2_stored_shipments.size() == max_stored_shipments:
            var p2_disliked_qualities :Array[QualityEnum.Property]
            for quality in p2_stored_shipments:
                if p2_shipping_dislikes.has(quality) and !p2_disliked_qualities.has(quality):
                    p2_disliked_qualities.append(quality)
            
            var average_score = average_int_array(p2_stored_scores)
            on_score_updated.emit(average_score)
            var disliked_qualities_from_shipment : Array[QualityEnum.Property]
            for quality in p2_shipping_dislikes:
                if p2_shipped_qualities.has(quality):
                    disliked_qualities_from_shipment.append(quality)
            var liked_qualitied_from_shipment : Array[QualityEnum.Property]
            for quality in p2_shipping_prefrences:
                if p2_shipped_qualities.has(quality):
                    liked_qualitied_from_shipment.append(quality)
            on_money_earned.emit(p2_money_earned_since_last_shipment)
            get_tree().get_first_node_in_group("ReportCard").show_report(
                p2_money_earned_since_last_shipment,disliked_qualities_from_shipment,liked_qualitied_from_shipment,average_score,"Report; Planet Gron"
                )
            p2_stored_shipments = []
            p2_stored_scores = []
            p2_money_earned_since_last_shipment = 0
            planet_2_shipped.emit(average_score)
    pass

func ship_item_planet_3(pickup : Pickup):
    p3_shipped_items += 1
    var item_score = calculate_shipped_score(pickup)
    p3_money_earned_since_last_shipment += item_score * MONEY_MULTIPLIER
    if p3_stored_shipments.size() < max_stored_shipments:
        p3_stored_shipments.append(pickup)
        p3_stored_scores.append(item_score)
        for quality in pickup.item_qualities:
            if !p3_shipped_qualities.has(quality):
                p3_shipped_qualities.append(quality)
        if p3_stored_shipments.size() == max_stored_shipments:
            var p3_disliked_qualities :Array[QualityEnum.Property]
            for quality in p3_stored_shipments:
                if p3_shipping_dislikes.has(quality) and !p3_disliked_qualities.has(quality):
                    p3_disliked_qualities.append(quality)
            
            var average_score = average_int_array(p3_stored_scores)
            on_score_updated.emit(average_score)
            var disliked_qualities_from_shipment : Array[QualityEnum.Property]
            for quality in p3_shipping_dislikes:
                if p3_shipped_qualities.has(quality):
                    disliked_qualities_from_shipment.append(quality)
            var liked_qualitied_from_shipment : Array[QualityEnum.Property]
            for quality in p3_shipping_prefrences:
                if p3_shipped_qualities.has(quality):
                    liked_qualitied_from_shipment.append(quality)
            on_money_earned.emit(p3_money_earned_since_last_shipment)
            get_tree().get_first_node_in_group("ReportCard").show_report(
                p3_money_earned_since_last_shipment,disliked_qualities_from_shipment,liked_qualitied_from_shipment,average_score,"Report; Planet Vorth"
                )
            p3_stored_shipments = []
            p3_stored_scores = []
            p3_money_earned_since_last_shipment = 0
            planet_3_shipped.emit(average_score)
    pass

func calculate_shipped_score(pickup : Pickup) -> int:
    var score = 0
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
