def humanize_date(date_str):
    date_format = "%Y-%m-%d %H:%M:%S"
    try:
        datetime_object = datetime.datetime.strptime(str(date_str), date_format)
        now = datetime.datetime.now()
        if datetime_object.date() == now.date():
            formatted_date = datetime_object.strftime('%I:%M %p')
        elif datetime_object.year < now.year:
            formatted_date = datetime_object.strftime('%m/%d/%y')
        else:
            formatted_date = datetime_object.strftime('%b %d')

        return formatted_date
    except Exception as error:
        print(error)
        return "Unknown Date"