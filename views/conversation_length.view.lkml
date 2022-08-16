view: conversation_length {
  derived_table: {
    sql:
      Select session_id, sentiment_score,
      start_time, end_time,
      count_of_msg, session_date_time, date
      from
      (SELECT session_id, avg(sentiment_score) as sentiment_score, min( time_stamp ) as start_time, max( time_stamp ) as end_time, count(distinct response_ID) as count_of_msg, MIN( time_stamp ) as session_date_time,
      min(date) as date
      FROM `@{gcp_project}.@{dataset}.dialogflow_cleaned_logs`
      group by session_id)
      ;;
  }

  ## added diamension
  dimension: count_of_msg_v2 {
    type: number
  }

  dimension: session_id {
    type: string
    primary_key: yes
  }

  dimension_group: conversation_duration {
    type: duration
    intervals: [second, minute]
    sql_start: conversation_length.start_time ;;
    sql_end: conversation_length.end_time ;;
  }

  dimension: count_of_msg {
    type: number
  }

  dimension_group: session_date_time {
    type: time
    timeframes: [
      raw,
      time,
      hour_of_day,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: yes
    datatype: datetime
  }

  dimension_group: date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: yes
    datatype: date
  }

  dimension: call_duration_bucket {
    case: {
      when: {
        sql: ${minutes_conversation_duration} < 1 ;;
        label: "< 1 min"
      }
      when: {
        sql: ${minutes_conversation_duration} < 3 and ${minutes_conversation_duration} >= 1;;
        label: "1-3 min"
      }
      when: {
        sql: ${minutes_conversation_duration} < 5 and ${minutes_conversation_duration} >= 3;;
        label: "3-5 min"
      }
      when: {
        sql: ${minutes_conversation_duration} < 7 and ${minutes_conversation_duration} >= 5;;
        label: "5-7 min"
      }
      else: "> 7 min"
    }
  }

  dimension: sentiment_score {
    hidden: yes
    type:  number
  }

  dimension: hour_frame {
    type: string
    sql: case WHEN ${session_date_time_hour_of_day} = 0 THEN "12am-1am"
      WHEN ${session_date_time_hour_of_day} = 1 THEN "1am-2am"
      WHEN ${session_date_time_hour_of_day} = 2 THEN "2am-3am"
      WHEN ${session_date_time_hour_of_day} = 3 THEN "3am-4am"
      WHEN ${session_date_time_hour_of_day} = 4 THEN "4am-5am"
      WHEN ${session_date_time_hour_of_day} = 5 THEN "5am-6am"
      WHEN ${session_date_time_hour_of_day} = 6 THEN "6am-7am"
      WHEN ${session_date_time_hour_of_day} = 7 THEN "7am-8am"
      WHEN ${session_date_time_hour_of_day} = 8 THEN "8am-9am"
      WHEN ${session_date_time_hour_of_day} = 9 THEN "9am-10am"
      WHEN ${session_date_time_hour_of_day} = 10 THEN "10am-11am"
      WHEN ${session_date_time_hour_of_day} = 11 THEN "11am-12pm"
      WHEN ${session_date_time_hour_of_day} = 12 THEN "12pm-1pm"
      WHEN ${session_date_time_hour_of_day} = 13 THEN "1pm-2pm"
      WHEN ${session_date_time_hour_of_day} = 14 THEN "2pm-3pm"
      WHEN ${session_date_time_hour_of_day} = 15 THEN "3pm-4pm"
      WHEN ${session_date_time_hour_of_day} = 16 THEN "4pm-5pm"
      WHEN ${session_date_time_hour_of_day} = 17 THEN "5pm-6pm"
      WHEN ${session_date_time_hour_of_day} = 18 THEN "6pm-7pm"
      WHEN ${session_date_time_hour_of_day} = 19 THEN "7pm-8pm"
      WHEN ${session_date_time_hour_of_day} = 20 THEN "8pm-9pm"
      WHEN ${session_date_time_hour_of_day} = 21 THEN "9pm-10pm"
      WHEN ${session_date_time_hour_of_day} = 22 THEN "10pm-11pm"
      WHEN ${session_date_time_hour_of_day} = 23 THEN "11pm-12pm"
      END
    ;;
  }

  measure: avg_call_duration_min {
    type: number
    hidden: yes
    sql: floor(avg(${minutes_conversation_duration})) ;;
  }

  measure: avg_call_duration_sec {
    type: number
    hidden: yes
    sql: mod(cast(avg(${seconds_conversation_duration}) as integer),60) ;;
  }

  measure: avg_session_duration {
    type: string
    sql: COALESCE(concat(cast(${avg_call_duration_min} as string),'m ',cast(${avg_call_duration_sec} as string),'s'),"0m 0s") ;;
  }

  measure: avg_sentiment_score {
    type: average
    sql: ${sentiment_score} ;;
  }

}
 
