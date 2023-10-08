; Create templates
(deftemplate FoodRecipe
   (slot name)
   (slot cuisine)
   (slot difficulty)
   (slot ingredients)
   (slot instructions)
)

(deftemplate DrinkRecipe
   (slot name)
   (slot temperature)
   (slot difficulty)
   (slot ingredients)
   (slot instructions)
)

(deftemplate Compatibility
   (slot food-name)
   (slot drink-name)
   (slot value)
)

(deftemplate User
   (slot name)
   (slot food-cuisine-preference)
   (slot drink-temp-preference)
   (slot difficulty-preference)
   (slot food-ingredient-preference)
   (slot drink-ingredient-preference)
)

(deftemplate FoodRecommendation
   (slot name)
   (slot ingredients)
   (slot instructions)
)

(deftemplate DrinkRecommendation
   (slot name)
   (slot ingredients)
   (slot instructions)
)

(deftemplate SetRecommendation
   (slot food-name)
   (slot food-ingredients)
   (slot food-instructions)
   (slot drink-name)
   (slot drink-ingredients)
   (slot drink-instructions)
   (slot compatibility-value)
)

(deftemplate BestSet
   (slot food-name)
   (slot drink-name)
)

; Create Rules

(defrule GetUserPreferences
    (not (User (name ?name)))
    =>
    ; inputs for user
    (printout t "insert your name !")
    (bind ?name (read))
    (printout t "Welcome, " ?name ". Let's find you a recipe!" crlf)
    (printout t "For the food, what cuisine do you prefer? ")
    (bind ?food-cuisine-pref (read))
    (printout t "For the drink, What temperature do you prefer? (Hot or Cold) ")
    (bind ?drink-temp-pref (read))
    (printout t "How difficult should the recipe be? (Easy, Intermediate, Difficult) ")
    (bind ?difficulty-pref (read))
    (printout t "Do you have any specific ingredient preferences for the food? ")
    (bind ?food-ingredient-pref (read))
    (printout t "Do you have any specific ingredient preferences for the drink? ")
    (bind ?drink-ingredient-pref (read))
    ; create new user fact
    (assert (User 
        (name ?name)
        (difficulty-preference ?difficulty-pref)
        (food-cuisine-preference ?food-cuisine-pref)
        (drink-temp-preference ?drink-temp-pref)
        (food-ingredient-preference ?food-ingredient-pref)
        (drink-ingredient-preference ?drink-ingredient-pref)
    ))
)


(defrule RecommendFoodRecipe
    (User 
        (name ?name)
        (food-cuisine-preference ?food-cuisine-pref)
        (difficulty-preference ?difficulty-pref)
        (food-ingredient-preference ?food-ingredient-pref)
    )
    (FoodRecipe 
        (name ?recipe)
        (cuisine ?cuisine)
        (difficulty ?difficulty)
        (ingredients ?ingredients)
        (instructions ?instructions)
    )
    (test (eq ?cuisine ?food-cuisine-pref))
    (test (eq ?difficulty ?difficulty-pref))
    (test (str-compare ?ingredients ?food-ingredient-pref))
    =>
    (assert (FoodRecommendation 
        (name ?recipe)
        (ingredients ?ingredients)
        (instructions ?instructions)
    ))
    ;(retract (User (name ?name)))
    ;(retract (Recipe (name ?recipe)))
)

(defrule RecommendDrinkRecipe
    (User 
        (name ?name)
        (drink-temp-preference ?drink-temp-pref)
        (difficulty-preference ?difficulty-pref)
        (drink-ingredient-preference ?drink-ingredient-pref)
    )
    (DrinkRecipe 
        (name ?recipe)
        (temperature ?temperature)
        (difficulty ?difficulty)
        (ingredients ?ingredients)
        (instructions ?instructions)
    )
    (test (eq ?temperature ?drink-temp-pref))
    (test (eq ?difficulty ?difficulty-pref))
    (test (str-compare ?ingredients ?drink-ingredient-pref))
    =>
    (assert (DrinkRecommendation 
        (name ?recipe)
        (ingredients ?ingredients)
        (instructions ?instructions)
    ))
    ;(retract (User (name ?name)))
    ;(retract (DrinkRecipe (name ?recipe)))
)

(defrule MatchFoodAndDrink
    (declare (salience -2))
    (FoodRecommendation 
        (name ?food-recom)
        (ingredients ?food-ingredients)
        (instructions ?food-instructions)
    )
    (DrinkRecommendation 
        (name ?drink-recom)
        (ingredients ?drink-ingredients)
        (instructions ?drink-instructions)
    )
    (Compatibility
        (food-name ?food-name)
        (drink-name ?drink-name)
        (value ?value)
    )
    (test (eq ?food-recom ?food-name))
    (test (eq ?drink-recom ?drink-name))
    =>
    (assert (SetRecommendation 
        (food-name ?food-name)
        (food-ingredients ?food-ingredients)
        (food-instructions ?food-instructions)
        (drink-name ?drink-name)
        (drink-ingredients ?drink-ingredients)
        (drink-instructions ?drink-instructions)
        (compatibility-value ?value)
    ))
    (printout t "Food: " ?food-name ", Drink: " ?drink-name " -> Compatibility Value: " ?value crlf)
)

(defrule GetBestSet
   (declare (salience -3))
   (SetRecommendation (food-name ?food1) (drink-name ?drink1) (compatibility-value ?value1))
   (not (SetRecommendation (compatibility-value ?value2&:(> ?value2 ?value1))))
   =>
   (assert (BestSet
        (food-name ?food1)
        (drink-name ?drink1)
    ))
)

(defrule PrintRecommendation
    (declare (salience -4))
    (SetRecommendation 
        (food-name ?food-recom)
        (food-ingredients ?food-ingredients)
        (food-instructions ?food-instructions)
        (drink-name ?drink-recom)
        (drink-ingredients ?drink-ingredients)
        (drink-instructions ?drink-instructions)
        (compatibility-value ?value)
    )
    (BestSet
        (food-name ?food-name)
        (drink-name ?drink-name)
    )
    (test (eq ?food-recom ?food-name))
    (test (eq ?drink-recom ?drink-name))
    =>
    (printout t crlf)
    (printout t "Based on your preferences, we recommend: " crlf)
    (printout t "Food: " ?food-name crlf)
    (printout t "- Ingredients: " ?food-ingredients crlf)
    (printout t "- Instructions: " ?food-instructions crlf)
    (printout t "Drink: " ?drink-name crlf)
    (printout t "- Ingredients: " ?drink-ingredients crlf)
    (printout t "- Instructions: " ?drink-instructions crlf)
)

(defrule NoRecommendation
    (declare (salience -4))
    (not (BestSet (food-name ?name) (drink-name ?drink-name)))
    =>
    (printout t crlf)
    (printout t "We are terribly sorry, but we can't recommend any recipe based on your preferences." crlf)
    (printout t "Stay tuned as more recipe data are coming soon or you can try another preferences :)" crlf)
)

(defrule ExitRecommendation
   (declare (salience -5))
   (User (name ?name))
   =>
   (printout t "Thank you for using the personalized recipe recommender, " ?name "!" crlf)
   ;(retract (User (name ?name)))
   ;(exit)
)

; set initial facts

(deffacts SampleFoodRecipes
    (FoodRecipe 
        (name "Spaghetti Carbonara") 
        (cuisine Italian) 
        (difficulty Easy)
        (ingredients "spaghetti, eggs, bacon, parmesan cheese") 
        (instructions "1. Cook spaghetti. 2. Fry bacon. 3. Mix eggs and cheese. 4. Toss with pasta.")
    )

    (FoodRecipe
        (name "Pizza") 
        (cuisine Italian) 
        (difficulty Difficult)
        (ingredients "flour, ketchup, tomato, onion, baking powder, olive oil, cheese, mushroom, oregano, mozzarella cheese, yeast, water") 
        (instructions "1. Cook spaghetti. 2. Fry bacon. 3. Mix eggs and cheese. 4. Toss with pasta.")
    )

    (FoodRecipe 
        (name "Chicken Tikka Masala") 
        (cuisine Indian) 
        (difficulty Intermediate)
        (ingredients "chicken, yogurt, tomato sauce, spices") 
        (instructions "1. Marinate chicken. 2. Cook chicken. 3. Simmer in sauce.")
    )

    (FoodRecipe 
        (name "Caesar Salad") 
        (cuisine American) 
        (difficulty Easy)
        (ingredients "romaine lettuce, croutons, caesar dressing") 
        (instructions "1. Toss lettuce with dressing. 2. Add croutons.")
    )

    (FoodRecipe
        (name "Bakso") 
        (cuisine Indonesian) 
        (difficulty Intermediate)
        (ingredients "ground meat, garlic, water, bones, onions, noodle") 
        (instructions "1. Mix ground meat with seasonings and shape into small meatballs. 2. Boil water with bones, garlic, and onions for flavor. 3. Strain, season, and simmer the broth. 4. Boil noodles until al dente. 5. Place noodles and meatballs in a bowl, pour hot broth, and garnish.")
    )

    (FoodRecipe 
        (name "Mie Aceh") 
        (cuisine Indonesian) 
        (difficulty Intermediate)
        (ingredients "noodle, water, oil, garlic, shallots, beef, Aceh chili paste, coconut milk, kaffir lime leaves, lemongrass") 
        (instructions "1. Boil water in a pot and cook your choice of noodles until al dente. 2. Heat oil in a separate pan and sauté garlic and shallots until fragrant. 3. Add beef and cook until browned. 4. Stir in Aceh chili paste and cook for a few minutes. 5. Pour in water and coconut milk, then add kaffir lime leaves and lemongrass. 6. Simmer until the broth thickens and the flavors meld. 7. Serve the cooked noodles in a bowl and pour the flavorful broth over them.")
    )
)

(deffacts SampleDrinkRecipes
    (DrinkRecipe 
        (name "Cappuccino") 
        (temperature Hot) 
        (difficulty Easy)
        (ingredients "coffee beans, water, milk") 
        (instructions "1. Grind fresh coffee beans to a fine espresso grind. 2. Use an espresso machine to brew a shot of espresso using the freshly ground coffee. 3. Steam and froth milk until it's creamy and has a velvety texture. 4. Pour the freshly brewed espresso into a cup and top it with the frothed milk.")
    )

    (DrinkRecipe 
        (name "Iced Milk Tea") 
        (temperature Cold) 
        (difficulty Difficult)
        (ingredients "tea leaf, milk, sugar, water") 
        (instructions "1. Brew strong black tea using tea leaf and let it cool. 2. Sweeten the tea to taste. 3. Fill a glass with ice and pour the tea over it. 4. Add milk, stir, and enjoy!")
    )

    (DrinkRecipe 
        (name "Wedang Jahe") 
        (temperature Hot) 
        (difficulty Intermediate)
        (ingredients "water, ginger, lemongrass, brown sugar") 
        (instructions "1. Boil water in a pot. 2. Add fresh ginger slices and crushed lemongrass. 3. Simmer for 10-15 minutes. 4. Add brown sugar and continue simmering until dissolved. 5. Strain into cups and serve hot.")
    )
)

(deffacts SampleCompatibilities
    (Compatibility
        (food-name "Spaghetti Carbonara")
        (drink-name "Cappuccino")
        (value 80)
    )

    (Compatibility
        (food-name "Spaghetti Carbonara")
        (drink-name "Ice Boba Milk Tea")
        (value 83)
    )

    (Compatibility
        (food-name "Spaghetti Carbonara")
        (drink-name "Wedang Jahe")
        (value 32)
    )

    (Compatibility
        (food-name "Pizza")
        (drink-name "Cappuccino")
        (value 85)
    )

    (Compatibility
        (food-name "Pizza")
        (drink-name "Ice Boba Milk Tea")
        (value 76)
    )

    (Compatibility
        (food-name "Pizza")
        (drink-name "Wedang Jahe")
        (value 34)
    )

    (Compatibility
        (food-name "Chicken Tikka Masala")
        (drink-name "Cappuccino")
        (value 63)
    )

    (Compatibility
        (food-name "Chicken Tikka Masala")
        (drink-name "Ice Boba Milk Tea")
        (value 88)
    )

    (Compatibility
        (food-name "Chicken Tikka Masala")
        (drink-name "Wedang Jahe")
        (value 31)
    )

    (Compatibility
        (food-name "Caesar Salad")
        (drink-name "Cappuccino")
        (value 84)
    )

    (Compatibility
        (food-name "Caesar Salad")
        (drink-name "Ice Boba Milk Tea")
        (value 87)
    )

    (Compatibility
        (food-name "Caesar Salad")
        (drink-name "Wedang Jahe")
        (value 29)
    )

    (Compatibility
        (food-name "Bakso")
        (drink-name "Cappuccino")
        (value 42)
    )

    (Compatibility
        (food-name "Bakso")
        (drink-name "Ice Boba Milk Tea")
        (value 92)
    )

    (Compatibility
        (food-name "Bakso")
        (drink-name "Wedang Jahe")
        (value 67)
    )

    (Compatibility
        (food-name "Mie Aceh")
        (drink-name "Cappuccino")
        (value 37)
    )

    (Compatibility
        (food-name "Mie Aceh")
        (drink-name "Ice Boba Milk Tea")
        (value 88)
    )

    (Compatibility
        (food-name "Mie Aceh")
        (drink-name "Wedang Jahe")
        (value 82)
    )
)