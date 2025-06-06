PGDMP                      }         	   terminal3    17.2    17.2 ?    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            �           1262    16953 	   terminal3    DATABASE     �   CREATE DATABASE terminal3 WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';
    DROP DATABASE terminal3;
                     postgres    false                        3079    16954    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                        false            �           0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                             false    2            )           1255    16991 M   fn_admin_add_useraccount(integer, character varying, text, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_admin_add_useraccount(p_admin_id integer, p_username character varying, p_password text, p_usertype character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_role VARCHAR;
    user_record JSONB;
    msg_type VARCHAR(20) DEFAULT 'error';
    msg_detail VARCHAR(200);
    user_exists BOOLEAN;
BEGIN
    user_record := NULL;
    msg_detail := '';

    SELECT usertype INTO user_role FROM useraccounts WHERE user_id = p_admin_id;

    IF user_role IS NULL THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'Admin user not found'
        );
    END IF;

    IF user_role <> 'admin' THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'Permission Denied: Only admins can add user accounts'
        );
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM useraccounts WHERE username = p_username
    ) INTO user_exists;

    IF NOT user_exists THEN
        INSERT INTO useraccounts (username, password, usertype) 
        VALUES (p_username, crypt(p_password, gen_salt('bf')), p_usertype); 

        SELECT to_jsonb(u)
        INTO user_record
        FROM useraccounts u
        WHERE u.username = p_username;

        IF FOUND THEN
            msg_type := 'success';
            msg_detail :='User ' || p_username || ' added successfully!';
        ELSE
            user_record := NULL;
            msg_type := 'error';
            msg_detail := p_username || ' User not found!';
        END IF;
    ELSE
        msg_type := 'error';
        msg_detail :=  p_username || ' User already exists!';
    END IF;

    RETURN jsonb_build_object(
        'content', user_record,
        'type', msg_type,
        'message', msg_detail
    );

EXCEPTION
    WHEN unique_violation THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'Unique violation! User already exists.'
        );
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'An unexpected error occurred: ' || SQLERRM
        );
END;
$$;
 �   DROP FUNCTION public.fn_admin_add_useraccount(p_admin_id integer, p_username character varying, p_password text, p_usertype character varying);
       public               postgres    false                       1255    16992 -   fn_admin_delete_useraccount(integer, integer)    FUNCTION     X  CREATE FUNCTION public.fn_admin_delete_useraccount(p_admin_id integer, p_user_id integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_role VARCHAR;
    user_exists BOOLEAN;
    msg_type VARCHAR(20) DEFAULT 'error';
    msg_detail VARCHAR(200);
BEGIN
    msg_detail := '';

    SELECT usertype INTO user_role FROM useraccounts WHERE user_id = p_admin_id;

    IF user_role IS NULL THEN
        RETURN jsonb_build_object(
            'type', 'error',
            'message', 'Admin user not found'
        );
    END IF;

    IF user_role <> 'admin' THEN
        RETURN jsonb_build_object(
            'type', 'error',
            'message', 'Permission Denied: Only admins can delete user accounts'
        );
    END IF;

    SELECT EXISTS (SELECT 1 FROM useraccounts WHERE user_id = p_user_id) INTO user_exists;

    IF user_exists THEN
        DELETE FROM useraccounts WHERE user_id = p_user_id;

        msg_type := 'success';
        msg_detail := 'User deleted successfully!';
    ELSE
        msg_type := 'error';
        msg_detail := 'User not found!';
    END IF;

    RETURN jsonb_build_object(
        'type', msg_type,
        'message', msg_detail
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'type', 'error',
            'message', 'An unexpected error occurred: ' || SQLERRM
        );
END;
$$;
 Y   DROP FUNCTION public.fn_admin_delete_useraccount(p_admin_id integer, p_user_id integer);
       public               postgres    false                       1255    16993 Y   fn_admin_update_useraccount(integer, integer, character varying, text, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_admin_update_useraccount(p_admin_id integer, p_user_id integer, p_username character varying, p_password text, p_usertype character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_role VARCHAR;
    msg_type VARCHAR(20) DEFAULT 'error';
    msg_detail VARCHAR(200);
    user_exists BOOLEAN;
BEGIN
    msg_detail := '';

    SELECT usertype INTO user_role FROM useraccounts WHERE user_id = p_admin_id;

    IF user_role IS NULL THEN
        RETURN jsonb_build_object('type', 'error', 'message', 'Admin user not found');
    END IF;

    IF user_role <> 'admin' THEN
        RETURN jsonb_build_object('type', 'error', 'message', 'Permission Denied: Only admins can update user accounts');
    END IF;

    SELECT EXISTS (SELECT 1 FROM useraccounts WHERE user_id = p_user_id) INTO user_exists;

    IF NOT user_exists THEN
        RETURN jsonb_build_object('type', 'error', 'message', 'User not found');
    END IF;

    UPDATE useraccounts 
    SET username = p_username, 
        password = crypt(p_password, gen_salt('bf', 12)), 
        usertype = p_usertype 
    WHERE user_id = p_user_id;

    msg_type := 'success';
    msg_detail := p_username || ' User updated successfully!';

    RETURN jsonb_build_object('type', msg_type, 'message', msg_detail);

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('type', 'error', 'message', 'An unexpected error occurred: ' || SQLERRM);
END;
$$;
 �   DROP FUNCTION public.fn_admin_update_useraccount(p_admin_id integer, p_user_id integer, p_username character varying, p_password text, p_usertype character varying);
       public               postgres    false                       1255    16994 O   fn_create_penalty(integer, character varying, date, numeric, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_create_penalty(p_user_id integer, p_violation character varying, p_violation_date date, p_amount_penalty numeric, p_plate_no character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$BEGIN
IF p_usertype = 'admin' THEN
       ELSIF operation_type = 'create_penalty' THEN

    INSERT INTO penalties (violation, violation_date, amount_penalty, plate_no, user_id)
    VALUES (p_violation, p_violation_date, p_amount_penalty, p_plate_no, p_user_id);
END IF;
END;
$$;
 �   DROP FUNCTION public.fn_create_penalty(p_user_id integer, p_violation character varying, p_violation_date date, p_amount_penalty numeric, p_plate_no character varying);
       public               postgres    false                       1255    16995 �   fn_create_vehicle(character varying, integer, character varying, character varying, character varying, character varying, character varying)    FUNCTION       CREATE FUNCTION public.fn_create_vehicle(p_usertype character varying, p_capacity integer DEFAULT NULL::integer, p_categories character varying DEFAULT NULL::character varying, p_driver_name character varying DEFAULT NULL::character varying, p_contact_no character varying DEFAULT NULL::character varying, p_plate_no character varying DEFAULT NULL::character varying, p_vehicle_name character varying DEFAULT NULL::character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_usertype = 'ordinary user' THEN
        -- Insert new vehicle record
        INSERT INTO vehicles (capacity, categories, driver_name, contact_no, vehicle_name, plate_no)
        VALUES (p_capacity, p_categories, p_driver_name, p_contact_no, p_vehicle_name, p_plate_no);
    END IF;
END;
$$;
 �   DROP FUNCTION public.fn_create_vehicle(p_usertype character varying, p_capacity integer, p_categories character varying, p_driver_name character varying, p_contact_no character varying, p_plate_no character varying, p_vehicle_name character varying);
       public               postgres    false                       1255    16996 �   fn_crud_user(character varying, integer, character varying, character varying, character varying, character varying, character varying)    FUNCTION     h  CREATE FUNCTION public.fn_crud_user(p_operation_type character varying, p_user_id integer DEFAULT NULL::integer, p_username character varying DEFAULT NULL::character varying, p_password character varying DEFAULT NULL::character varying, p_fullname character varying DEFAULT NULL::character varying, p_usertype character varying DEFAULT NULL::character varying, p_plate_no character varying DEFAULT NULL::character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Ensure the user is admin to perform operations
    IF p_usertype = 'admin' THEN
        IF p_operation_type = 'create_user' THEN
            -- Call function to create a new user
            PERFORM public.fn_create_user(p_username, p_password, p_fullname, p_usertype, p_plate_no);

        ELSIF p_operation_type = 'update_user' THEN
            -- Call function to update an existing user
            PERFORM public.fn_update_user(p_user_id, p_username, p_password, p_fullname, p_usertype, p_plate_no);

        ELSIF p_operation_type = 'delete_user' THEN
            -- Call function to delete a user
            PERFORM public.fn_delete_user(p_user_id);

        ELSIF p_operation_type = 'create_penalty' THEN
            -- Call function to create a new penalty for the user
            PERFORM public.fn_create_penalty(p_user_id, p_violation, p_violation_date, p_amount_penalty, p_plate_no);

        ELSIF p_operation_type = 'update_penalty' THEN
            -- Call function to update an existing penalty
            PERFORM public.fn_update_penalty(p_penalty_id, p_violation, p_violation_date, p_amount_penalty);

        END IF;
    END IF;
END;
$$;
 �   DROP FUNCTION public.fn_crud_user(p_operation_type character varying, p_user_id integer, p_username character varying, p_password character varying, p_fullname character varying, p_usertype character varying, p_plate_no character varying);
       public               postgres    false                       1255    16997 %   fn_delete_schedule(character varying)    FUNCTION       CREATE FUNCTION public.fn_delete_schedule(p_plate_no character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
IF p_usertype = 'ordinary user' THEN
       ELSIF operation_type = 'delete_schedule' THEN
    DELETE FROM schedules WHERE plate_no = p_plate_no;
	END IF;
END;
$$;
 G   DROP FUNCTION public.fn_delete_schedule(p_plate_no character varying);
       public               postgres    false                       1255    16998    fn_delete_user(integer)    FUNCTION     �   CREATE FUNCTION public.fn_delete_user(p_user_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
IF p_usertype = 'admin' THEN
    DELETE FROM useraccounts WHERE user_id = p_user_id;
	END IF;
END;
$$;
 8   DROP FUNCTION public.fn_delete_user(p_user_id integer);
       public               postgres    false                       1255    16999 �   fn_delete_vehicle(character varying, character varying, integer, character varying, character varying, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_delete_vehicle(p_usertype character varying, p_operation_type character varying, p_capacity integer DEFAULT NULL::integer, p_categories character varying DEFAULT NULL::character varying, p_driver_name character varying DEFAULT NULL::character varying, p_contact_no character varying DEFAULT NULL::character varying, p_plate_no character varying DEFAULT NULL::character varying, p_vehicle_name character varying DEFAULT NULL::character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_usertype = 'ordinary user' THEN
        IF p_operation_type = 'delete_vehicle' THEN
            -- Delete vehicle based on plate number
            DELETE FROM vehicles WHERE plate_no = p_plate_no;
        END IF;
    END IF;
END;
$$;
   DROP FUNCTION public.fn_delete_vehicle(p_usertype character varying, p_operation_type character varying, p_capacity integer, p_categories character varying, p_driver_name character varying, p_contact_no character varying, p_plate_no character varying, p_vehicle_name character varying);
       public               postgres    false                       1255    17000 b   fn_insert_penalty(character varying, date, numeric, character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.fn_insert_penalty(p_violation character varying, p_violation_date date, p_penalty_amount numeric, p_plate_no character varying, p_created_by character varying, p_user_id integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    penalty_record JSONB;
    msg_type VARCHAR(20);
    msg_detail VARCHAR(200);
BEGIN
    -- Initialize variables
    penalty_record := NULL;
    msg_type := '';
    msg_detail := '';

    -- Insert the new penalty
    INSERT INTO penalties (violation, violation_date, penalty_amount, plate_no, created_by, user_id)
    VALUES (p_violation, p_violation_date, p_penalty_amount, p_plate_no, p_created_by, p_user_id)
    RETURNING to_jsonb(penalties.*) INTO penalty_record;

    -- Check if the record was inserted successfully
    IF penalty_record IS NOT NULL THEN
        msg_type := 'success';
        msg_detail := 'Penalty added successfully!';
    ELSE
        msg_type := 'error';
        msg_detail := 'Failed to insert penalty.';
    END IF;

    -- Return JSON response
    RETURN jsonb_build_object(
        'status', msg_type,
        'message', msg_detail,
        'data', penalty_record
    );
END;
$$;
 �   DROP FUNCTION public.fn_insert_penalty(p_violation character varying, p_violation_date date, p_penalty_amount numeric, p_plate_no character varying, p_created_by character varying, p_user_id integer);
       public               postgres    false                       1255    17001 r   fn_insert_schedule(character varying, timestamp without time zone, timestamp without time zone, character varying)    FUNCTION     w  CREATE FUNCTION public.fn_insert_schedule(p_plate_no character varying, p_departure_time timestamp without time zone, p_arrival_time timestamp without time zone, p_destination character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_record JSONB;
    msg_type VARCHAR(20) DEFAULT 'error';
    msg_detail VARCHAR(200);
BEGIN
    user_record := NULL;
    msg_detail := '';

    INSERT INTO schedules (departure_time, arrival_time, destination, plate_no)
    VALUES (p_departure_time, p_arrival_time, p_destination, p_plate_no)
    RETURNING to_jsonb(schedules) INTO user_record;

    IF FOUND THEN
        msg_type := 'success';
        msg_detail := 'Schedule added successfully!';
    ELSE
        msg_type := 'error';
        msg_detail := 'Failed to add schedule!';
    END IF;

    RETURN jsonb_build_object(
        'content', user_record,
        'type', msg_type,
        'message', msg_detail
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'An unexpected error occurred: ' || SQLERRM
        );
END;
$$;
 �   DROP FUNCTION public.fn_insert_schedule(p_plate_no character varying, p_departure_time timestamp without time zone, p_arrival_time timestamp without time zone, p_destination character varying);
       public               postgres    false                       1255    17002 m   fn_insert_user(character varying, character varying, character varying, character varying, character varying)    FUNCTION       CREATE FUNCTION public.fn_insert_user(p_username character varying, p_password character varying, p_fullname character varying, p_usertype character varying, p_operation character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_record JSONB;
    msg_type VARCHAR(20);
    msg_detail VARCHAR(200);
    user_exists BOOLEAN;
    hashed_password VARCHAR;
BEGIN
    -- Initialize variables
    user_record := NULL;
    msg_type := '';
    msg_detail := '';

    -- Check operation 
    IF p_operation = 'Add' THEN
        -- Check if the username exists
        SELECT EXISTS (
            SELECT 1 FROM useraccounts WHERE username = p_username
        ) INTO user_exists; 

        IF NOT user_exists THEN
            -- Hash the password before storing
            hashed_password := crypt(p_password, gen_salt('bf'));

            INSERT INTO useraccounts (username, password, fullname, usertype) 
            VALUES (p_username, hashed_password, p_fullname, p_usertype);

            -- Retrieve the inserted user record
            SELECT to_jsonb(u) INTO user_record
            FROM useraccounts u WHERE u.username = p_username;

            msg_type := 'success';
            msg_detail := p_username || ' added successfully!';
        ELSE
            msg_type := 'error';
            msg_detail := p_username || ' already exists!';
        END IF;
    END IF;

    -- Return JSON response
    RETURN jsonb_build_object(
        'status', msg_type,
        'message', msg_detail,
        'data', user_record
    );
END;
$$;
 �   DROP FUNCTION public.fn_insert_user(p_username character varying, p_password character varying, p_fullname character varying, p_usertype character varying, p_operation character varying);
       public               postgres    false                       1255    17003    fn_login(character varying)    FUNCTION     �  CREATE FUNCTION public.fn_login(p_username character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    stored_password TEXT;
BEGIN
    SELECT password INTO stored_password FROM useraccounts WHERE username = p_username;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('type', 'error', 'message', 'User not found');
    END IF;

    RETURN jsonb_build_object('password', stored_password);
END;
$$;
 =   DROP FUNCTION public.fn_login(p_username character varying);
       public               postgres    false                       1255    17004 9   fn_mark_penalty_as_paid(integer, date, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_mark_penalty_as_paid(p_penalty_id integer, p_paid_date date, p_or_no character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_record JSONB; -- JSON storage for updated records
    msg_type VARCHAR(20);
    msg_detail VARCHAR(200);
BEGIN
    -- Initialize variables
    user_record := NULL;
    msg_type := '';
    msg_detail := '';

    -- Update the penalty record
    UPDATE penalties SET
        paid = TRUE,
        paid_date = COALESCE(p_paid_date, CURRENT_DATE),  -- Defaults to current date if not provided
        or_no = p_or_no
    WHERE penalty_id = p_penalty_id
    RETURNING to_jsonb(penalties.*) INTO user_record;

    -- Check if the update was successful
    IF user_record IS NOT NULL THEN
        msg_type := 'success';
        msg_detail := 'Penalty marked as paid!';
    ELSE
        msg_type := 'error';
        msg_detail := 'Penalty not found!';
    END IF;

    -- Return JSON response
    RETURN jsonb_build_object(
        'content', user_record,
        'type', msg_type,
        'message', msg_detail
    );

EXCEPTION
    WHEN unique_violation THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'Unique violation!'
        );
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'An unexpected error occurred: ' || SQLERRM
        );
END;
$$;
 q   DROP FUNCTION public.fn_mark_penalty_as_paid(p_penalty_id integer, p_paid_date date, p_or_no character varying);
       public               postgres    false                       1255    17005    fn_o_user_add_schedule(integer, character varying, timestamp without time zone, timestamp without time zone, character varying)    FUNCTION     �
  CREATE FUNCTION public.fn_o_user_add_schedule(p_or_id integer, p_plate_no character varying, p_departure_time timestamp without time zone, p_arrival_time timestamp without time zone, p_destination character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_role VARCHAR;
    schedule_record JSONB;
    msg_type VARCHAR(20) DEFAULT 'error';
    msg_detail VARCHAR(200);
    schedule_exists BOOLEAN;
    new_schedule_id INTEGER;
BEGIN
    schedule_record := NULL;
    msg_detail := '';

    -- Check if admin exists and has correct permissions
    SELECT usertype INTO user_role FROM useraccounts WHERE user_id = p_or_id;

    IF user_role IS NULL THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'Admin user not found'
        );
    END IF;

    IF user_role <> 'ordinary user' THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'Permission Denied: Only users can add a new schedule'
        );
    END IF;

    -- Check if a schedule already exists for the same event at the same time
    SELECT EXISTS (
        SELECT 1 FROM schedules 
        WHERE destination = p_destination 
        AND departure_time = p_departure_time
        AND arrival_time = p_arrival_time
        AND plate_no = p_plate_no
    ) INTO schedule_exists;

    IF NOT schedule_exists THEN
        -- Insert new schedule and return the generated schedule_id
        INSERT INTO schedules (departure_time, arrival_time, destination, plate_no)
    VALUES (p_departure_time, p_arrival_time, p_destination, p_plate_no)
        RETURNING schedule_id INTO new_schedule_id;

        -- Retrieve the inserted schedule
        SELECT to_jsonb(s) 
        INTO schedule_record
        FROM schedules s
        WHERE s.schedule_id = new_schedule_id;

        IF FOUND THEN
            msg_type := 'success';
            msg_detail := 'New schedule added successfully!';
        ELSE
            schedule_record := NULL;
            msg_type := 'error';
            msg_detail := 'Schedule not found after insertion!';
        END IF;
    ELSE
        msg_type := 'error';
        msg_detail := 'This schedule already exists!';
    END IF;

    RETURN jsonb_build_object(
        'content', schedule_record,
        'type', msg_type,
        'message', msg_detail
    );

EXCEPTION
    WHEN unique_violation THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'Unique violation! Schedule already exists.'
        );
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'An unexpected error occurred: ' || SQLERRM
        );
END;
$$;
 �   DROP FUNCTION public.fn_o_user_add_schedule(p_or_id integer, p_plate_no character varying, p_departure_time timestamp without time zone, p_arrival_time timestamp without time zone, p_destination character varying);
       public               postgres    false                        1255    17006 b   fn_update_penalty(integer, character varying, date, numeric, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_update_penalty(p_penalty_id integer, p_violation character varying, p_violation_date date, p_penalty_amount numeric, p_plate_no character varying, p_usertype character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_record JSONB;
    msg_type VARCHAR(20);
    msg_detail VARCHAR(200);
BEGIN
    user_record := NULL;
    msg_type := '';
    msg_detail := '';

    -- Ensure only admins can update penalties
    IF p_usertype = 'admin' THEN
        UPDATE penalties 
        SET 
            violation = COALESCE(p_violation, violation),
            violation_date = COALESCE(p_violation_date, violation_date),
            penalty_amount = COALESCE(p_penalty_amount, penalty_amount),
            plate_no = COALESCE(p_plate_no, plate_no)
        WHERE penalty_id = p_penalty_id
        RETURNING to_jsonb(penalties.*) INTO user_record;

        IF user_record IS NOT NULL THEN
            msg_type := 'success';
            msg_detail := 'Penalty updated successfully!';
        ELSE
            msg_type := 'error';
            msg_detail := 'Penalty not found!';
        END IF;
    ELSE
        msg_type := 'error';
        msg_detail := 'User type must be "admin".';
    END IF;

    RETURN jsonb_build_object(
        'content', user_record,
        'type', msg_type,
        'message', msg_detail
    );

EXCEPTION
    WHEN unique_violation THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'Unique violation!'
        );
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'An unexpected error occurred: ' || SQLERRM
        );
END;
$$;
 �   DROP FUNCTION public.fn_update_penalty(p_penalty_id integer, p_violation character varying, p_violation_date date, p_penalty_amount numeric, p_plate_no character varying, p_usertype character varying);
       public               postgres    false            !           1255    17007 r   fn_update_schedule(character varying, timestamp without time zone, timestamp without time zone, character varying)    FUNCTION     Z  CREATE FUNCTION public.fn_update_schedule(p_plate_no character varying, p_departure_time timestamp without time zone, p_arrival_time timestamp without time zone, p_destination character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
IF p_usertype = 'ordinary user' THEN
       ELSIF operation_type = 'update_schedule' THEN
    UPDATE schedules SET
        departure_time = COALESCE(p_departure_time, departure_time),
        arrival_time = COALESCE(p_arrival_time, arrival_time),
        destination = COALESCE(p_destination, destination)
    WHERE plate_no = p_plate_no;
	END IF;
END;
$$;
 �   DROP FUNCTION public.fn_update_schedule(p_plate_no character varying, p_departure_time timestamp without time zone, p_arrival_time timestamp without time zone, p_destination character varying);
       public               postgres    false            "           1255    17008 m   fn_update_user(character varying, character varying, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_update_user(p_username character varying, p_password character varying, p_fullname character varying, p_usertype character varying, p_operation character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_record JSONB; -- JSON storage for added or updated records
    msg_type VARCHAR(20);
    msg_detail VARCHAR(200);
    user_exists BOOLEAN;
BEGIN

    -- Initialize variables
    user_record := NULL;
    msg_type := '';
    msg_detail := '';
        
    -- Check operation 
    IF p_operation = 'Update' THEN
        -- Update user account 
        IF p_usertype = 'admin' THEN
            UPDATE useraccounts
            SET password = p_password,
                usertype = p_usertype,
                fullname = p_fullname
            WHERE username = p_username
            RETURNING to_jsonb(useraccount) INTO user_record;

            IF user_record IS NOT NULL THEN
                msg_type := 'success';
                msg_detail := p_username || ' updated successfully!';
            ELSE
                msg_type := 'error';
                msg_detail := p_username || ' not found!';
            END IF;
        ELSE
            msg_type := 'error';
            msg_detail := 'User type must be "admin".';
        END IF;
    ELSE
        msg_type := 'error';
        msg_detail := p_operation || ' operation not found!';
    END IF;

    -- RETURN for successful execution
    RETURN jsonb_build_object(
        'content', user_record,
        'type', msg_type,
        'message', msg_detail
    );

EXCEPTION
    WHEN unique_violation THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'Unique violation!'
        );
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'An unexpected error occurred: ' || SQLERRM
        );

END;
$$;
 �   DROP FUNCTION public.fn_update_user(p_username character varying, p_password character varying, p_fullname character varying, p_usertype character varying, p_operation character varying);
       public               postgres    false            #           1255    17009 �   fn_update_vehicle(character varying, character varying, integer, character varying, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_update_vehicle(p_usertype character varying, p_plate_no character varying, p_capacity integer DEFAULT NULL::integer, p_categories character varying DEFAULT NULL::character varying, p_driver_name character varying DEFAULT NULL::character varying, p_contact_no character varying DEFAULT NULL::character varying, p_vehicle_name character varying DEFAULT NULL::character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_usertype = 'ordinary user' THEN
        -- Update existing vehicle record based on plate number
        UPDATE vehicles SET
            capacity = COALESCE(p_capacity, capacity),
            categories = COALESCE(p_categories, categories),
            driver_name = COALESCE(p_driver_name, driver_name),
            contact_no = COALESCE(p_contact_no, contact_no),
            vehicle_name = COALESCE(p_vehicle_name, vehicle_name)
        WHERE plate_no = p_plate_no;
    END IF;
END;
$$;
 �   DROP FUNCTION public.fn_update_vehicle(p_usertype character varying, p_plate_no character varying, p_capacity integer, p_categories character varying, p_driver_name character varying, p_contact_no character varying, p_vehicle_name character varying);
       public               postgres    false            $           1255    17010 ^   pr_crud_penalties(integer, character varying, date, numeric, boolean, date, character varying) 	   PROCEDURE     q  CREATE PROCEDURE public.pr_crud_penalties(IN p_penalty_id integer DEFAULT NULL::integer, IN p_violation character varying DEFAULT NULL::character varying, IN p_violation_date date DEFAULT NULL::date, IN p_amount_penalty numeric DEFAULT NULL::numeric, IN p_paid boolean DEFAULT NULL::boolean, IN p_paid_date date DEFAULT NULL::date, IN p_or_no character varying DEFAULT NULL::character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
IF p_usertype = 'admin' THEN
       ELSIF operation_type = 'create_penalty' THEN
            INSERT INTO penalties (violation, violation_date, amount_penalty, plate_no, user_id)
            VALUES (p_violation, p_violation_date, p_amount_penalty, p_plate_no, p_user_id);

        ELSIF operation_type = 'update_penalty' THEN
            UPDATE penalties SET
                violation = COALESCE(p_violation, violation),
                violation_date = COALESCE(p_violation_date, violation_date),
                amount_penalty = COALESCE(p_amount_penalty, amount_penalty)
            WHERE penalty_id = p_penalty_id;

        ELSIF operation_type = 'mark_penalty_as_paid' THEN
            UPDATE penalties SET
                paid = TRUE,
                paid_date = COALESCE(p_paid_date, CURRENT_DATE),  -- If no paid_date is provided, it defaults to current date
                or_no = p_or_no
            WHERE penalty_id = p_penalty_id;
		END IF;
END;
$$;
 �   DROP PROCEDURE public.pr_crud_penalties(IN p_penalty_id integer, IN p_violation character varying, IN p_violation_date date, IN p_amount_penalty numeric, IN p_paid boolean, IN p_paid_date date, IN p_or_no character varying);
       public               postgres    false            %           1255    17011 p   pr_crud_schedule(character varying, timestamp without time zone, timestamp without time zone, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.pr_crud_schedule(IN p_plate_no character varying DEFAULT NULL::character varying, IN p_departure_time timestamp without time zone DEFAULT NULL::timestamp without time zone, IN p_arrival_time timestamp without time zone DEFAULT NULL::timestamp without time zone, IN p_destination character varying DEFAULT NULL::character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_usertype = 'user' THEN
        ELSIF operation_type = 'create_schedule' THEN
            INSERT INTO schedules (departure_time, arrival_time, destination, plate_no)
            VALUES (p_departure_time, p_arrival_time, p_destination, p_plate_no);

        ELSIF operation_type = 'update_schedule' THEN
            UPDATE schedules SET
                departure_time = COALESCE(p_departure_time, departure_time),
                arrival_time = COALESCE(p_arrival_time, arrival_time),
                destination = COALESCE(p_destination, destination)
            WHERE plate_no = p_plate_no;  -- Assuming schedules are identified by plate_no

        ELSIF operation_type = 'delete_schedule' THEN
            DELETE FROM schedules WHERE plate_no = p_plate_no; 
	END IF;
END;
$$;
 �   DROP PROCEDURE public.pr_crud_schedule(IN p_plate_no character varying, IN p_departure_time timestamp without time zone, IN p_arrival_time timestamp without time zone, IN p_destination character varying);
       public               postgres    false            &           1255    17012 �   pr_crud_user(character varying, integer, character varying, character varying, character varying, character varying, character varying) 	   PROCEDURE     B  CREATE PROCEDURE public.pr_crud_user(IN operation_type character varying, IN p_user_id integer DEFAULT NULL::integer, IN p_username character varying DEFAULT NULL::character varying, IN p_password character varying DEFAULT NULL::character varying, IN p_fullname character varying DEFAULT NULL::character varying, IN p_usertype character varying DEFAULT NULL::character varying, IN p_plate_no character varying DEFAULT NULL::character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
IF p_usertype = 'admin' THEN
       ELSIF operation_type = 'create_user' THEN
            INSERT INTO useraccounts (username, password, usertype,fullname, plate_no)
            VALUES (p_username, p_password,p_fullname, p_usertype, p_plate_no);

        ELSIF operation_type = 'update_user' THEN
            UPDATE useraccounts SET
                username = COALESCE(p_username, username),
                password = COALESCE(p_password, password),
				fullname = COALESCE(p_fullname, fullname),
                usertype = COALESCE(p_usertype, usertype),
                plate_no = COALESCE(p_plate_no, plate_no)
            WHERE user_id = p_user_id;

        ELSIF operation_type = 'delete_user' THEN
            DELETE FROM useraccounts WHERE user_id = p_user_id;

        ELSIF operation_type = 'create_penalty' THEN
            INSERT INTO penalties (violation, violation_date, amount_penalty, plate_no, user_id)
            VALUES (p_violation, p_violation_date, p_amount_penalty, p_plate_no, p_user_id);

        ELSIF operation_type = 'update_penalty' THEN
            UPDATE penalties SET
                violation = COALESCE(p_violation, violation),
                violation_date = COALESCE(p_violation_date, violation_date),
                amount_penalty = COALESCE(p_amount_penalty, amount_penalty)
            WHERE penalty_id = p_penalty_id;
		END IF;
END;
$$;
   DROP PROCEDURE public.pr_crud_user(IN operation_type character varying, IN p_user_id integer, IN p_username character varying, IN p_password character varying, IN p_fullname character varying, IN p_usertype character varying, IN p_plate_no character varying);
       public               postgres    false            '           1255    17013 x   pr_deletevehicle(integer, character varying, character varying, character varying, character varying, character varying) 	   PROCEDURE     q  CREATE PROCEDURE public.pr_deletevehicle(IN p_capacity integer DEFAULT NULL::integer, IN p_categories character varying DEFAULT NULL::character varying, IN p_driver_name character varying DEFAULT NULL::character varying, IN p_contact_no character varying DEFAULT NULL::character varying, IN p_plate_no character varying DEFAULT NULL::character varying, IN p_vehicle_name character varying DEFAULT NULL::character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_usertype = 'user' THEN
        ELSIF operation_type = 'delete_vehicle' THEN
            DELETE FROM vehicles WHERE plate_no = p_plate_no;
		END IF;
END;
$$;
 �   DROP PROCEDURE public.pr_deletevehicle(IN p_capacity integer, IN p_categories character varying, IN p_driver_name character varying, IN p_contact_no character varying, IN p_plate_no character varying, IN p_vehicle_name character varying);
       public               postgres    false            (           1255    17014 r   pr_vehicle(integer, character varying, character varying, character varying, character varying, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.pr_vehicle(IN p_capacity integer DEFAULT NULL::integer, IN p_categories character varying DEFAULT NULL::character varying, IN p_driver_name character varying DEFAULT NULL::character varying, IN p_contact_no character varying DEFAULT NULL::character varying, IN p_plate_no character varying DEFAULT NULL::character varying, IN p_vehicle_name character varying DEFAULT NULL::character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_usertype = 'user' THEN
        ELSIF operation_type = 'create_vehicle' THEN
            INSERT INTO vehicles (capacity, categories, driver_name, contact_no, vehicle_name, plate_no)
            VALUES (p_capacity, p_categories, p_driver_name, p_contact_no, p_vehicle_name, p_plate_no);

        ELSIF operation_type = 'update_vehicle' THEN
            UPDATE vehicles SET
                capacity = COALESCE(p_capacity, capacity),
                categories = COALESCE(p_categories, categories),
                driver_name = COALESCE(p_driver_name, driver_name),
				contact_no = COALESCE(p_contact_no, contact_no),
				vehicle_name = COALESCE(p_vehicle_name, vehicle_name)
            WHERE plate_no = p_plate_no;
		END IF;
END;
$$;
 �   DROP PROCEDURE public.pr_vehicle(IN p_capacity integer, IN p_categories character varying, IN p_driver_name character varying, IN p_contact_no character varying, IN p_plate_no character varying, IN p_vehicle_name character varying);
       public               postgres    false            �            1259    17015 	   penalties    TABLE     1  CREATE TABLE public.penalties (
    penalty_id integer NOT NULL,
    violation character varying(100),
    violation_date date,
    penalty_amount numeric(10,2),
    paid boolean DEFAULT false,
    paid_date date,
    or_no character varying(20),
    plate_no character varying(8),
    user_id integer
);
    DROP TABLE public.penalties;
       public         heap r       postgres    false            �            1259    17019    penalties_penalty_id_seq    SEQUENCE     �   CREATE SEQUENCE public.penalties_penalty_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.penalties_penalty_id_seq;
       public               postgres    false    218            �           0    0    penalties_penalty_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.penalties_penalty_id_seq OWNED BY public.penalties.penalty_id;
          public               postgres    false    219            �            1259    17020 	   schedules    TABLE     �   CREATE TABLE public.schedules (
    schedule_id integer NOT NULL,
    departure_time timestamp without time zone,
    arrival_time timestamp without time zone,
    destination character varying(100),
    plate_no character varying(8)
);
    DROP TABLE public.schedules;
       public         heap r       postgres    false            �            1259    17023    schedules_schedule_id_seq    SEQUENCE     �   CREATE SEQUENCE public.schedules_schedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.schedules_schedule_id_seq;
       public               postgres    false    220            �           0    0    schedules_schedule_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.schedules_schedule_id_seq OWNED BY public.schedules.schedule_id;
          public               postgres    false    221            �            1259    17024    useraccounts    TABLE     �   CREATE TABLE public.useraccounts (
    user_id integer NOT NULL,
    username character varying NOT NULL,
    password text NOT NULL,
    plate_no character varying(8),
    fullname character varying,
    usertype character varying
);
     DROP TABLE public.useraccounts;
       public         heap r       postgres    false            �            1259    17029    useraccounts_user_id_seq    SEQUENCE     �   CREATE SEQUENCE public.useraccounts_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.useraccounts_user_id_seq;
       public               postgres    false    222            �           0    0    useraccounts_user_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.useraccounts_user_id_seq OWNED BY public.useraccounts.user_id;
          public               postgres    false    223            �            1259    17030    vehicles    TABLE     �   CREATE TABLE public.vehicles (
    plate_no character varying(8) NOT NULL,
    capacity integer,
    categories character varying(20),
    driver_name character varying(60),
    contact_no character varying(20),
    vehicle_name character varying(60)
);
    DROP TABLE public.vehicles;
       public         heap r       postgres    false            �            1259    17033    vw_schedule    VIEW     =  CREATE VIEW public.vw_schedule AS
 SELECT vehicles.plate_no,
    vehicles.categories,
    vehicles.driver_name,
    schedules.departure_time,
    schedules.arrival_time,
    schedules.destination
   FROM (public.schedules
     LEFT JOIN public.vehicles ON (((schedules.plate_no)::text = (vehicles.plate_no)::text)));
    DROP VIEW public.vw_schedule;
       public       v       postgres    false    220    220    220    220    224    224    224            �            1259    17037 
   vw_vehicle    VIEW     �   CREATE VIEW public.vw_vehicle AS
 SELECT driver_name,
    categories,
    capacity
   FROM public.vehicles
  WHERE ((categories)::text = 'Van'::text);
    DROP VIEW public.vw_vehicle;
       public       v       postgres    false    224    224    224            �           2604    17041    penalties penalty_id    DEFAULT     |   ALTER TABLE ONLY public.penalties ALTER COLUMN penalty_id SET DEFAULT nextval('public.penalties_penalty_id_seq'::regclass);
 C   ALTER TABLE public.penalties ALTER COLUMN penalty_id DROP DEFAULT;
       public               postgres    false    219    218            �           2604    17042    schedules schedule_id    DEFAULT     ~   ALTER TABLE ONLY public.schedules ALTER COLUMN schedule_id SET DEFAULT nextval('public.schedules_schedule_id_seq'::regclass);
 D   ALTER TABLE public.schedules ALTER COLUMN schedule_id DROP DEFAULT;
       public               postgres    false    221    220            �           2604    17043    useraccounts user_id    DEFAULT     |   ALTER TABLE ONLY public.useraccounts ALTER COLUMN user_id SET DEFAULT nextval('public.useraccounts_user_id_seq'::regclass);
 C   ALTER TABLE public.useraccounts ALTER COLUMN user_id DROP DEFAULT;
       public               postgres    false    223    222            �          0    17015 	   penalties 
   TABLE DATA           �   COPY public.penalties (penalty_id, violation, violation_date, penalty_amount, paid, paid_date, or_no, plate_no, user_id) FROM stdin;
    public               postgres    false    218   $�       �          0    17020 	   schedules 
   TABLE DATA           e   COPY public.schedules (schedule_id, departure_time, arrival_time, destination, plate_no) FROM stdin;
    public               postgres    false    220   ��       �          0    17024    useraccounts 
   TABLE DATA           a   COPY public.useraccounts (user_id, username, password, plate_no, fullname, usertype) FROM stdin;
    public               postgres    false    222   ��       �          0    17030    vehicles 
   TABLE DATA           i   COPY public.vehicles (plate_no, capacity, categories, driver_name, contact_no, vehicle_name) FROM stdin;
    public               postgres    false    224   ��       �           0    0    penalties_penalty_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.penalties_penalty_id_seq', 6, true);
          public               postgres    false    219            �           0    0    schedules_schedule_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.schedules_schedule_id_seq', 6, true);
          public               postgres    false    221            �           0    0    useraccounts_user_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.useraccounts_user_id_seq', 21, true);
          public               postgres    false    223            �           2606    17045    penalties penalties_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.penalties
    ADD CONSTRAINT penalties_pkey PRIMARY KEY (penalty_id);
 B   ALTER TABLE ONLY public.penalties DROP CONSTRAINT penalties_pkey;
       public                 postgres    false    218            �           2606    17047    schedules schedules_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (schedule_id);
 B   ALTER TABLE ONLY public.schedules DROP CONSTRAINT schedules_pkey;
       public                 postgres    false    220            �           2606    17049    useraccounts useraccounts_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.useraccounts
    ADD CONSTRAINT useraccounts_pkey PRIMARY KEY (user_id);
 H   ALTER TABLE ONLY public.useraccounts DROP CONSTRAINT useraccounts_pkey;
       public                 postgres    false    222            �           2606    17051 &   useraccounts useraccounts_plate_no_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.useraccounts
    ADD CONSTRAINT useraccounts_plate_no_key UNIQUE (plate_no);
 P   ALTER TABLE ONLY public.useraccounts DROP CONSTRAINT useraccounts_plate_no_key;
       public                 postgres    false    222            �           2606    17053    vehicles vehicles_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (plate_no);
 @   ALTER TABLE ONLY public.vehicles DROP CONSTRAINT vehicles_pkey;
       public                 postgres    false    224            �           1259    17054    idx_user    INDEX     E   CREATE INDEX idx_user ON public.useraccounts USING btree (username);
    DROP INDEX public.idx_user;
       public                 postgres    false    222            �           1259    17055    idx_violation    INDEX     X   CREATE INDEX idx_violation ON public.penalties USING btree (violation, violation_date);
 !   DROP INDEX public.idx_violation;
       public                 postgres    false    218    218            �           2606    17056 !   penalties penalties_plate_no_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.penalties
    ADD CONSTRAINT penalties_plate_no_fkey FOREIGN KEY (plate_no) REFERENCES public.vehicles(plate_no);
 K   ALTER TABLE ONLY public.penalties DROP CONSTRAINT penalties_plate_no_fkey;
       public               postgres    false    218    4840    224            �           2606    17061     penalties penalties_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.penalties
    ADD CONSTRAINT penalties_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.useraccounts(user_id);
 J   ALTER TABLE ONLY public.penalties DROP CONSTRAINT penalties_user_id_fkey;
       public               postgres    false    218    4836    222            �           2606    17066 !   schedules schedules_plate_no_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_plate_no_fkey FOREIGN KEY (plate_no) REFERENCES public.vehicles(plate_no);
 K   ALTER TABLE ONLY public.schedules DROP CONSTRAINT schedules_plate_no_fkey;
       public               postgres    false    220    224    4840            �           2606    17071 '   useraccounts useraccounts_plate_no_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.useraccounts
    ADD CONSTRAINT useraccounts_plate_no_fkey FOREIGN KEY (plate_no) REFERENCES public.vehicles(plate_no);
 Q   ALTER TABLE ONLY public.useraccounts DROP CONSTRAINT useraccounts_plate_no_fkey;
       public               postgres    false    4840    224    222            �   �   x�u��
�0�s�}��$m�;�y����.C�De���:,*䐄��G {���Z�O���jf-ܵ����t6W�`������X�M`84�e�&���1�h�J�u`���͂�z�U�{rOTq���=��ibm��}����D�c����h��E��-S,#D|C�KX      �   �   x�]���0Eם���̔VJw�#.�DݨqScBL�.�o!(H2��{����XF� KnȘlܲ�U^̲9���>c�ոXbY7,w�+�C,�+�&&����Hi�~�XZ�V���?��|�)���$!�h�a_���WW�����W��S����a�[=���u��� >`k<G      �   6  x�m�ٮ�Z�k|
.�m\�r	��� ���ð�Adx����}b�H*�WU�(0l�
'H���uWV��DtzS�eT�P����<-fb��-��H�
6�JZ����T�"m�'hD�dX$ލ�;������)���TI�ж�ՌB�(�+�y5j+��F��N��_E��2�@�j��<�i��!C �V̀���p���
m����J.�:�p�`Ns��^tf�L/X�r8������r�w��U|WWFanw��vɓ�^�(��=�2�%�ޮ��1��پai��)�8�,���d�?=�6%�C�, �͛���~�\����L��uR�ȑ��t+�G������0���HK{'�aiP\T��~x8�$���s���PX���"�	E�-%;�����ﰠ���5�_G�����k��kηv�������'X����HL����>l!w�"�=���קP��1���@F�M^�H�࡭i�����*��)�v�ˍn�[ZPy6ѵ\1�{Pf�?+������N��i�/YN�`z��8c��ȇ�x<�`�*���d��������:M�ߜ��jL���]��Vܦ�c��L�Ե=a-)y�\�������蚯��Y�Q����w?k݇�����fɢ�<�X�(�qs����^`�s�[n���E3�5��3� ��G;;7��*|���Ѡl�>@����yB1$V�ki 4kR��D�o��7��^,	�[�E��Ӑ����?'$�ߠ�gL��(��%W�8�`t��\�=G���&�]��4�P��Ԕ����f��O�X      �   �   x�5���0��ۧ�'0m��X=5Q��ڤ(����-��=��73�Y6GƣX���FiFM�=O��0"KV�Ju_I<��z�OR�A�5}ۑ�z�)�XO�-�O���.�/��h��d�+�7������b֚�vx��~�C��|A� ����.�we�3�(JJ]�#�uD�3`@�     