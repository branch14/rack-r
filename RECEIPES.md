Receipes
========

Boxplot the ages of users
-------------------------

    svg('0_user_age.svg')
    users <- dbReadTable(con, 'users')
    users$age <- round(as.numeric(as.Date(users$birth_date) - Sys.Date()) / -365.25)
    boxplot(users$age)


Output a html table of data
---------------------------

    some_data <- dbReadTable(con, 'some_table')
    write.csv(some_data, file='some_data.csv')


Control the order of content
----------------------------

The resulting files are processed/included aplhabetically. So if you
name you output devices accordingly, you can control the order. E.g.

    svg('1st_graphic_is_a_sinus.svg')
    plot(sin)
    svg('2nd_graphic_is_a_cosinus.svg')
    plot(cos)

