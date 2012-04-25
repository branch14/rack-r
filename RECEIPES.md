Receipes
========

Boxplot the ages of users
-------------------------

    svg('0_user_age.svg')
    users <- dbReadTable(con, 'users')
    users$age <- round(as.numeric(as.Date(users$birth_date) - Sys.Date()) / -365.25)
    boxplot(users$age)


Header which connects to Sqlite3 or MySQL
-----------------------------------------

    library(yaml)
    library(DBI)
    library(RSQLite)
    library(RMySQL)
    root <- '<%= Rails.root %>'
    dbconf <- yaml.load_file(paste(root, '/config/database.yml', sep=''))$<%= Rails.env %>
    if(dbconf$adapter=='sqlite3') {
      dbfile <- paste(root, '/', dbconf$database, sep='')
      drv <- dbDriver("SQLite")
      con <- dbConnect(drv, dbname=dbfile)
    } else if (dbconf$adapter=='mysql') {
      con <- dbConnect(MySQL(), user=dbconf$username, dbname=dbconf$database)
    }


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

