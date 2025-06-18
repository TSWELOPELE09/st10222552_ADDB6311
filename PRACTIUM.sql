Create table EVENT
(
  EVENT_ID           number(5)        not null    primary key,
  EVENT_NAME         varchar2(100)    not null,
  EVENT_RATE        number(5)     not null
 );
Create table ARTIST
(
  ARTIST_ID            varchar2(5)    not null    primary key,
  ARTIST_NAME         varchar2(100)  not null,
  ARTIST_EMAIL        varchar2(100)  not null
  );
Create table BOOKINGS
(
  BOOKING_ID              number    not null    primary key,
  BOOKING_DATE            date           not null,
  EVENT_ID 		         number(5)	not null,
  ARTIST_ID             varchar2(5)        not null,
FOREIGN KEY (EVENT_ID) REFERENCES EVENT(EVENT_ID),
FOREIGN KEY (ARTIST_ID) REFERENCES ARTIST(ARTIST_ID)
); 


insert all
   into EVENT(EVENT_ID, EVENT_NAME, EVENT_RATE)
    values(1001, 'Open Air Comedy Festival', 300)
into EVENT(EVENT_ID, EVENT_NAME, EVENT_RATE)
    values(1002, 'Mountain Side Music Festival', 280)
into EVENT(EVENT_ID, EVENT_NAME, EVENT_RATE)
    values(1003, 'Beach Music Festival', 195)
  
Select * from dual;
Commit;

insert all
   into ARTIST(ARTIST_ID, ARTIST_NAME, ARTIST_EMAIL)
    values('A_101', 'Max Trillion', 'maxt@isat.com')
 into ARTIST(ARTIST_ID, ARTIST_NAME, ARTIST_EMAIL)
    values('A_102', 'Music Mayhem', 'mayhem@ymail.com')
into ARTIST(ARTIST_ID, ARTIST_NAME, ARTIST_EMAIL)
    values('A_103', 'LOL Man', 'lol@isat.com')
       Select * from dual;
  Commit;
  
insert all
   into BOOKINGS(BOOKING_ID, BOOKING_DATE, EVENT_ID, ARTIST_ID)
    values(1, '15 July 2024', 1002, 'A_101')
 into BOOKINGS(BOOKING_ID, BOOKING_DATE, EVENT_ID, ARTIST_ID)
    values(2, '15 July 2024', 1002, 'A_102')
 into BOOKINGS(BOOKING_ID, BOOKING_DATE, EVENT_ID, ARTIST_ID)
    values(3, '27 August 2024', 1001, 'A_103')
 into BOOKINGS(BOOKING_ID, BOOKING_DATE, EVENT_ID, ARTIST_ID)
    values(4, '30 August 2024', 1003, 'A_101')
into BOOKINGS(BOOKING_ID, BOOKING_DATE, EVENT_ID, ARTIST_ID)
    values(5, '30 August 2024', 1003, 'A_102')

      Select * from dual;
Commit;

SELECT 
    b.BOOKING_ID,
    b.BOOKING_DATE,
    e.EVENT_NAME,
    e.EVENT_RATE,
    a.ARTIST_NAME,
    a.ARTIST_EMAIL
FROM 
    BOOKINGS b
JOIN 
    EVENT e ON b.EVENT_ID = e.EVENT_ID
JOIN 
    ARTIST a ON b.ARTIST_ID = a.ARTIST_ID;
    
        
SELECT 
    a.ARTIST_ID,
    a.ARTIST_NAME,
    a.ARTIST_EMAIL,
    COUNT(b.BOOKING_ID) AS PERFORMANCE_COUNT
FROM 
    ARTIST a
LEFT JOIN 
    BOOKINGS b ON a.ARTIST_ID = b.ARTIST_ID
GROUP BY 
    a.ARTIST_ID, a.ARTIST_NAME, a.ARTIST_EMAIL
HAVING 
    COUNT(b.BOOKING_ID) = (
        SELECT MIN(CNT)
        FROM (
            SELECT 
                COUNT(b2.BOOKING_ID) AS CNT
            FROM 
                ARTIST a2
            LEFT JOIN 
                BOOKINGS b2 ON a2.ARTIST_ID = b2.ARTIST_ID
            GROUP BY 
                a2.ARTIST_ID
        )
    );

SELECT 
    a.ARTIST_NAME,
    SUM(TO_NUMBER(REPLACE(e.EVENT_RATE, 'R ', ''))) AS TOTAL_REVENUE
FROM 
    ARTIST a
JOIN 
    BOOKINGS b ON a.ARTIST_ID = b.ARTIST_ID
JOIN 
    EVENT e ON b.EVENT_ID = e.EVENT_ID
GROUP BY 
    a.ARTIST_NAME
    
SET SERVEROUTPUT ON;

DECLARE
    v_artist_name   ARTIST.ARTIST_NAME%TYPE;
    v_booking_date  BOOKINGS.BOOKING_DATE%TYPE;

    CURSOR artist_cursor IS
        SELECT 
            a.ARTIST_NAME,
            b.BOOKING_DATE
        FROM 
            BOOKINGS b
        JOIN 
            ARTIST a ON b.ARTIST_ID = a.ARTIST_ID
        WHERE 
            b.EVENT_ID = 1001;
BEGIN
    FOR record IN artist_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Artist Name: ' || record.ARTIST_NAME ||
                             ' | Booking Date: ' || TO_CHAR(record.BOOKING_DATE, 'DD-MON-YYYY'));
    END LOOP;
END;

SET SERVEROUTPUT ON;

DECLARE
    v_event_name     EVENT.EVENT_NAME%TYPE;
    v_event_rate     EVENT.EVENT_RATE%TYPE;
    v_clean_rate     NUMBER;
    v_discounted     NUMBER;
    
    CURSOR event_cursor IS
        SELECT EVENT_NAME, EVENT_RATE
        FROM EVENT;
BEGIN
    FOR record IN event_cursor LOOP

        v_clean_rate := TO_NUMBER(REPLACE(record.EVENT_RATE, 'R ', ''));

        
        IF v_clean_rate > 200 THEN
            v_discounted := v_clean_rate * 0.9;
            DBMS_OUTPUT.PUT_LINE('Event: ' || record.EVENT_NAME ||
                                 ' | Original Price: R ' || v_clean_rate ||
                                 ' | Discounted Price: R ' || TO_CHAR(v_discounted, '999.99'));
        ELSE
            DBMS_OUTPUT.PUT_LINE('Event: ' || record.EVENT_NAME ||
                                 ' | Price: R ' || v_clean_rate ||
                                 ' | No Discount');
        END IF;
    END LOOP;
END;

CREATE OR REPLACE VIEW Event_Schedules AS
SELECT DISTINCT
    e.EVENT_NAME
FROM
    EVENT e
JOIN
    BOOKINGS b ON e.EVENT_ID = b.EVENT_ID
WHERE
    b.BOOKING_DATE BETWEEN TO_DATE('01-JUL-2024', 'DD-MON-YYYY')
                       AND TO_DATE('28-AUG-2024', 'DD-MON-YYYY');

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE GetBookingDetailsByArtist (
    p_artist_name IN ARTIST.ARTIST_NAME%TYPE
) IS
BEGIN
    FOR rec IN (
        SELECT 
            b.BOOKING_ID,
            b.BOOKING_DATE,
            e.EVENT_NAME,
            e.EVENT_RATE
        FROM 
            BOOKINGS b
        JOIN 
            ARTIST a ON b.ARTIST_ID = a.ARTIST_ID
        JOIN
            EVENT e ON b.EVENT_ID = e.EVENT_ID
        WHERE 
            a.ARTIST_NAME = p_artist_name
        ORDER BY
            b.BOOKING_DATE
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Booking ID: ' || rec.BOOKING_ID ||
                             ' | Booking Date: ' || TO_CHAR(rec.BOOKING_DATE, 'DD-MON-YYYY') ||
                             ' | Event Name: ' || rec.EVENT_NAME ||
                             ' | Event Rate: ' || rec.EVENT_RATE);
    END LOOP;
END;
/
BEGIN
    GetBookingDetailsByArtist('Max Trillion');
END;
/

CREATE OR REPLACE FUNCTION fn_TotalArtistRevenue (
    p_artist_id IN ARTIST.ARTIST_ID%TYPE
) RETURN NUMBER IS

    v_total_revenue NUMBER := 0;

BEGIN
    SELECT 
        SUM(TO_NUMBER(REPLACE(e.EVENT_RATE, 'R ', '')))
    INTO 
        v_total_revenue
    FROM 
        BOOKINGS b
    JOIN 
        EVENT e ON b.EVENT_ID = e.EVENT_ID
    WHERE 
        b.ARTIST_ID = p_artist_id;

    
    IF v_total_revenue IS NULL THEN
        v_total_revenue := 0;
    END IF;

    RETURN v_total_revenue;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
    
        RETURN -1; 
END;
/
SET SERVEROUTPUT ON;

DECLARE
    v_artist_id   ARTIST.ARTIST_ID%TYPE := 'A_101';  
    v_revenue     NUMBER;
BEGIN
    v_revenue := fn_TotalArtistRevenue(v_artist_id);

    IF v_revenue = -1 THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred while calculating revenue.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Total revenue for artist ' || v_artist_id || ' is: R ' || v_revenue);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END;
/



CREATE OR REPLACE TRIGGER trg_prevent_invalid_booking
BEFORE INSERT OR UPDATE ON BOOKINGS
FOR EACH ROW
DECLARE
    v_day NUMBER;
BEGIN
    
    v_day := TO_CHAR(:NEW.BOOKING_DATE, 'D');

    IF v_day = 1 OR v_day = 7 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Bookings are not allowed on weekends.');
    END IF;
END;

INSERT INTO BOOKINGS (BOOKING_ID, BOOKING_DATE, EVENT_ID, ARTIST_ID)
VALUES (101, TO_DATE('15-JUN-2025', 'DD-MON-YYYY'), 1001, 'A_101');


