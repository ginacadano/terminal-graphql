PGDMP      
                }            terminal    17.2    17.2 @    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            �           1262    34049    terminal    DATABASE     �   CREATE DATABASE terminal WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_Philippines.1252';
    DROP DATABASE terminal;
                     postgres    false                        3079    34050    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                        false            �           0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                             false    2            	           1255    34087 R   fn_admin_add_penalty(integer, character varying, date, numeric, character varying)    FUNCTION     �	  CREATE FUNCTION public.fn_admin_add_penalty(p_admin_id integer, p_violation character varying, p_violation_date date, p_amount_penalty numeric, p_plate_no character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_role VARCHAR;
    penalty_record JSONB;
    msg_type VARCHAR(20) DEFAULT 'error';
    msg_detail VARCHAR(200);
    penalty_exists BOOLEAN;
    new_penalty_id INTEGER;
BEGIN
    penalty_record := NULL;
    msg_detail := '';

    -- Check if admin user exists
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
            'message', 'Permission Denied: Only admins can add penalties'
        );
    END IF;

    -- Check if penalty already exists
    SELECT EXISTS (
        SELECT 1 FROM penalties 
        WHERE violation = p_violation
        AND violation_date = p_violation_date 
        AND amount_penalty = p_amount_penalty
        AND plate_no = p_plate_no
    ) INTO penalty_exists;

    IF NOT penalty_exists THEN
        -- Insert new penalty and return penalty_id
        INSERT INTO penalties (violation, violation_date, amount_penalty, plate_no)
        VALUES (p_violation, p_violation_date, p_amount_penalty, p_plate_no)
        RETURNING penalty_id INTO new_penalty_id;

        -- Fetch penalty record
        SELECT to_jsonb(p) INTO penalty_record
        FROM penalties p
        WHERE p.penalty_id = new_penalty_id;

        msg_type := 'success';
        msg_detail := p_violation || ' penalty added successfully!';
    ELSE
        msg_type := 'error';
        msg_detail := p_violation || ' penalty already exists!';
    END IF;

    RETURN jsonb_build_object(
        'content', penalty_record,
        'type', msg_type,
        'message', msg_detail
    );

EXCEPTION
    WHEN unique_violation THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'Unique violation! Penalty already exists.'
        );
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'An unexpected error occurred: ' || SQLERRM
        );
END;
$$;
 �   DROP FUNCTION public.fn_admin_add_penalty(p_admin_id integer, p_violation character varying, p_violation_date date, p_amount_penalty numeric, p_plate_no character varying);
       public               postgres    false                       1255    34088 M   fn_admin_add_useraccount(integer, character varying, text, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_admin_add_useraccount(p_admin_id integer, p_username character varying, p_password text, p_usertype character varying) RETURNS jsonb
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
       public               postgres    false                       1255    34089 �   fn_admin_add_vehicle(integer, integer, character varying, character varying, character varying, character varying, character varying)    FUNCTION     �
  CREATE FUNCTION public.fn_admin_add_vehicle(p_admin_id integer, p_capacity integer, p_categories character varying, p_driver_name character varying, p_contact_no character varying, p_vehicle_name character varying, p_plate_no character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_role VARCHAR;
    vehicle_record JSONB;
    msg_type VARCHAR(20) DEFAULT 'error';
    msg_detail VARCHAR(200);
    vehicle_exists BOOLEAN;
    new_plate_no character varying;
BEGIN
    vehicle_record := NULL;
    msg_detail := '';

    -- Check if admin user exists
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
            'message', 'Permission Denied: Only admins can add vehicles'
        );
    END IF;

    -- Check if vehicle already exists (use AND instead of ADD)
    SELECT EXISTS (
        SELECT 1 FROM vehicles 
        WHERE capacity = p_capacity
        AND categories = p_categories
        AND driver_name = p_driver_name
        AND contact_no = p_contact_no  -- FIXED: Use AND, not ADD
        AND vehicle_name = p_vehicle_name  -- FIXED: Use AND, not ADD
        AND plate_no = p_plate_no
    ) INTO vehicle_exists;

    IF NOT vehicle_exists THEN
        -- Insert new vehicle
        INSERT INTO vehicles (capacity, categories, driver_name, contact_no, vehicle_name, plate_no)
        VALUES (p_capacity, p_categories, p_driver_name, p_contact_no, p_vehicle_name, p_plate_no)
        RETURNING plate_no INTO new_plate_no;

        -- Fetch vehicle record
        SELECT to_jsonb(v) INTO vehicle_record
        FROM vehicles v
        WHERE v.plate_no = new_plate_no;

        msg_type := 'success';
        msg_detail := p_vehicle_name || ' vehicle added successfully!';
    ELSE
        msg_type := 'error';
        msg_detail := p_vehicle_name || ' vehicle already exists!';
    END IF;

    RETURN jsonb_build_object(
        'content', vehicle_record,
        'type', msg_type,
        'message', msg_detail
    );

EXCEPTION
    WHEN unique_violation THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'Unique violation! Vehicle already exists.'
        );
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'An unexpected error occurred: ' || SQLERRM
        );
END;
$$;
 �   DROP FUNCTION public.fn_admin_add_vehicle(p_admin_id integer, p_capacity integer, p_categories character varying, p_driver_name character varying, p_contact_no character varying, p_vehicle_name character varying, p_plate_no character varying);
       public               postgres    false                       1255    34090 -   fn_admin_delete_useraccount(integer, integer)    FUNCTION     X  CREATE FUNCTION public.fn_admin_delete_useraccount(p_admin_id integer, p_user_id integer) RETURNS jsonb
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
       public               postgres    false                       1255    34091 3   fn_admin_delete_vehicle(integer, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_admin_delete_vehicle(p_admin_id integer, p_plate_no character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_role VARCHAR;
    vehicle_exists BOOLEAN;
    msg_type VARCHAR(20) DEFAULT 'error';
    msg_detail VARCHAR(200);
BEGIN
    -- Check if admin user exists
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
            'message', 'Permission Denied: Only admins can delete vehicles'
        );
    END IF;

    -- Check if the vehicle exists
    SELECT EXISTS (
        SELECT 1 FROM vehicles WHERE plate_no = p_plate_no
    ) INTO vehicle_exists;

    IF vehicle_exists THEN
        -- Delete the vehicle
        DELETE FROM vehicles WHERE plate_no = p_plate_no;

        msg_type := 'success';
        msg_detail := 'Vehicle with plate number ' || p_plate_no || ' deleted successfully!';
    ELSE
        msg_type := 'error';
        msg_detail := 'Vehicle with plate number ' || p_plate_no || ' does not exist!';
    END IF;

    RETURN jsonb_build_object(
        'content', NULL,
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
 `   DROP FUNCTION public.fn_admin_delete_vehicle(p_admin_id integer, p_plate_no character varying);
       public               postgres    false                       1255    34092 ^   fn_admin_update_penalty(integer, integer, character varying, date, numeric, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_admin_update_penalty(p_admin_id integer, p_penalty_id integer, p_violation character varying, p_violation_date date, p_amount_penalty numeric, p_plate_no character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_role VARCHAR;
    penalty_record JSONB;
    msg_type VARCHAR(20) DEFAULT 'error';
    msg_detail VARCHAR(200);
    penalty_exists BOOLEAN;
BEGIN
    penalty_record := NULL;
    msg_detail := '';

    -- Check if admin user exists
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
            'message', 'Permission Denied: Only admins can update penalties'
        );
    END IF;

    -- Check if penalty exists
    SELECT EXISTS (
        SELECT 1 FROM penalties
        WHERE penalty_id = p_penalty_id
    ) INTO penalty_exists;

    IF NOT penalty_exists THEN
        msg_type := 'error';
        msg_detail := 'Penalty with ID ' || p_penalty_id || ' does not exist!';
    ELSE
        -- Update the penalty record
        UPDATE penalties
        SET violation = p_violation,
            violation_date = p_violation_date,
            amount_penalty = p_amount_penalty,
            plate_no = p_plate_no
        WHERE penalty_id = p_penalty_id;

        -- Fetch the updated penalty record
        SELECT to_jsonb(p) INTO penalty_record
        FROM penalties p
        WHERE p.penalty_id = p_penalty_id;

        msg_type := 'success';
        msg_detail := 'Penalty with ID ' || p_penalty_id || ' updated successfully!';
    END IF;

    -- Return the response in JSON format
    RETURN jsonb_build_object(
        'content', penalty_record,
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
 �   DROP FUNCTION public.fn_admin_update_penalty(p_admin_id integer, p_penalty_id integer, p_violation character varying, p_violation_date date, p_amount_penalty numeric, p_plate_no character varying);
       public               postgres    false                       1255    34093 Y   fn_admin_update_useraccount(integer, integer, character varying, text, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_admin_update_useraccount(p_admin_id integer, p_user_id integer, p_username character varying, p_password text, p_usertype character varying) RETURNS jsonb
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
       public               postgres    false                       1255    34094 �   fn_admin_update_vehicle(integer, integer, character varying, integer, character varying, character varying, character varying, character varying)    FUNCTION     /	  CREATE FUNCTION public.fn_admin_update_vehicle(p_admin_id integer, p_vehicle_id integer, p_plate_no character varying, p_capacity integer, p_categories character varying, p_driver_name character varying, p_contact_no character varying, p_vehicle_name character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_role VARCHAR;
    vehicle_record JSONB;
    msg_type VARCHAR(20) DEFAULT 'error';
    msg_detail VARCHAR(200);
    vehicle_exists BOOLEAN;
BEGIN
    vehicle_record := NULL;
    msg_detail := '';

    -- Check if admin user exists
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
            'message', 'Permission Denied: Only admins can update penalties'
        );
    END IF;

    -- Check if penalty exists
    SELECT EXISTS (
        SELECT 1 FROM vehicles
        WHERE vehicle_id = p_vehicle_id
    ) INTO vehicle_exists;

    IF NOT vehicle_exists THEN
        msg_type := 'error';
        msg_detail := 'Vehicle with ID ' || p_vehicle_id || ' does not exist!';
    ELSE
        -- Update the penalty record
        UPDATE vehicles
        SET plate_no = p_plate_no,
            capacity = p_capacity,
            categories = p_categories,
            driver_name = p_driver_name,
			contact_no = p_contact_no,
			vehicle_name = p_vehicle_name
        WHERE vehicle_id = p_vehicle_id;

        -- Fetch the updated penalty record
        SELECT to_jsonb(v) INTO vehicle_record
        FROM vehicles v
        WHERE v.vehicle_id = p_vehicle_id;

        msg_type := 'success';
        msg_detail := 'Vehicle with ID ' || p_vehicle_id || ' updated successfully!';
    END IF;

    -- Return the response in JSON format
    RETURN jsonb_build_object(
        'content', vehicle_record,
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
   DROP FUNCTION public.fn_admin_update_vehicle(p_admin_id integer, p_vehicle_id integer, p_plate_no character varying, p_capacity integer, p_categories character varying, p_driver_name character varying, p_contact_no character varying, p_vehicle_name character varying);
       public               postgres    false                       1255    34095 %   fn_delete_schedule(character varying)    FUNCTION       CREATE FUNCTION public.fn_delete_schedule(p_plate_no character varying) RETURNS void
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
       public               postgres    false                       1255    34096    fn_delete_user(integer)    FUNCTION     �   CREATE FUNCTION public.fn_delete_user(p_user_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
IF p_usertype = 'admin' THEN
    DELETE FROM useraccounts WHERE user_id = p_user_id;
	END IF;
END;
$$;
 8   DROP FUNCTION public.fn_delete_user(p_user_id integer);
       public               postgres    false                       1255    34097 �   fn_delete_vehicle(character varying, character varying, integer, character varying, character varying, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_delete_vehicle(p_usertype character varying, p_operation_type character varying, p_capacity integer DEFAULT NULL::integer, p_categories character varying DEFAULT NULL::character varying, p_driver_name character varying DEFAULT NULL::character varying, p_contact_no character varying DEFAULT NULL::character varying, p_plate_no character varying DEFAULT NULL::character varying, p_vehicle_name character varying DEFAULT NULL::character varying) RETURNS void
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
       public               postgres    false                       1255    34098    fn_login(character varying)    FUNCTION     �  CREATE FUNCTION public.fn_login(p_username character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    stored_password TEXT;
    stored_username VARCHAR;
    stored_usertype VARCHAR;
    stored_user_id INT;
BEGIN    
    SELECT user_id, password, username, usertype
    INTO stored_user_id, stored_password, stored_username, stored_usertype
    FROM useraccounts
    WHERE username = p_username;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('type', 'error', 'message', 'User not found');
    END IF;

    RETURN jsonb_build_object(
        'user_id', stored_user_id,
        'password', stored_password,
        'username', stored_username,
        'usertype', stored_usertype
    );
END;
$$;
 =   DROP FUNCTION public.fn_login(p_username character varying);
       public               postgres    false                       1255    34099 9   fn_mark_penalty_as_paid(integer, date, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_mark_penalty_as_paid(p_penalty_id integer, p_paid_date date, p_or_no character varying) RETURNS jsonb
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
       public               postgres    false                        1255    34100 w   fn_or_add_schedule(integer, date, character varying, time without time zone, time without time zone, character varying)    FUNCTION     u  CREATE FUNCTION public.fn_or_add_schedule(p_or_id integer, p_date date, p_plate_no character varying, p_departure_time time without time zone, p_arrival_time time without time zone, p_destination character varying) RETURNS jsonb
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

    -- Check if Ordinary user exists
    SELECT usertype INTO user_role FROM useraccounts WHERE user_id = p_or_id;

    IF user_role IS NULL THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'Ordinary user not found'
        );
    END IF;

    IF user_role <> 'ordinary user' THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'Permission Denied: Only Ordinary user can add penalties'
        );
    END IF;

    -- Check if penalty already exists
     SELECT EXISTS (
        SELECT 1 FROM schedules 
        WHERE date = p_date
        AND departure_time = p_departure_time
        AND arrival_time = p_arrival_time
		AND destination = p_destination 
		AND plate_no = p_plate_no
    ) INTO schedule_exists;

    IF NOT schedule_exists THEN
        -- Insert new penalty and return penalty_id
        INSERT INTO schedules (date, departure_time, arrival_time, destination, plate_no)
    VALUES (p_date, p_departure_time, p_arrival_time, p_destination, p_plate_no)
        RETURNING schedule_id INTO new_schedule_id;

        -- Fetch penalty record
        SELECT to_jsonb(p) INTO schedule_record
        FROM schedules p
        WHERE p.schedule_id = new_schedule_id;

        msg_type := 'success';
        msg_detail := p_date || ' Schedule added successfully!';
    ELSE
        msg_type := 'error';
        msg_detail := p_date || ' Schedule already exists!';
    END IF;

    RETURN jsonb_build_object(
        'content', schedule_record,
        'type', msg_type,
        'message', msg_detail
    );
END;
$$;
 �   DROP FUNCTION public.fn_or_add_schedule(p_or_id integer, p_date date, p_plate_no character varying, p_departure_time time without time zone, p_arrival_time time without time zone, p_destination character varying);
       public               postgres    false            !           1255    34101 '   fn_or_delete_schedule(integer, integer)    FUNCTION       CREATE FUNCTION public.fn_or_delete_schedule(p_or_id integer, p_schedule_id integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_role VARCHAR;
    msg_type VARCHAR(20) DEFAULT 'error';
    msg_detail VARCHAR(200);
    schedule_exists BOOLEAN;
BEGIN
    msg_detail := '';

    -- Check if admin user exists
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
            'message', 'Permission Denied: Only Ordinary user can delete schedules'
        );
    END IF;

    -- Check if the schedule exists
    SELECT EXISTS (
        SELECT 1 FROM schedules
        WHERE schedule_id = p_schedule_id
    ) INTO schedule_exists;

    IF NOT schedule_exists THEN
        msg_type := 'error';
        msg_detail := 'Schedule with ID ' || p_schedule_id || ' does not exist!';
    ELSE
        -- Delete the schedule
        DELETE FROM schedules WHERE schedule_id = p_schedule_id;

        msg_type := 'success';
        msg_detail := 'Schedule ID ' || p_schedule_id || ' deleted successfully!';
    END IF;

    -- Return the response in JSON format
    RETURN jsonb_build_object(
        'content', NULL,
        'type', msg_type,
        'message', msg_detail
    );
END;
$$;
 T   DROP FUNCTION public.fn_or_delete_schedule(p_or_id integer, p_schedule_id integer);
       public               postgres    false            "           1255    34102 �   fn_or_update_schedule(integer, integer, date, character varying, time without time zone, time without time zone, character varying)    FUNCTION     [  CREATE FUNCTION public.fn_or_update_schedule(p_or_id integer, p_schedule_id integer, p_date date, p_plate_no character varying, p_departure_time time without time zone, p_arrival_time time without time zone, p_destination character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_role VARCHAR;
    schedule_record JSONB;
    msg_type VARCHAR(20) DEFAULT 'error';
    msg_detail VARCHAR(200);
    schedule_exists BOOLEAN;
BEGIN
    schedule_record := NULL;
    msg_detail := '';

    -- Check if Ordinary user exists
    SELECT usertype INTO user_role FROM useraccounts WHERE user_id = p_or_id;

    IF user_role IS NULL THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'Ordinary user not found'
        );
    END IF;

    IF user_role <> 'ordinary user' THEN
        RETURN jsonb_build_object(
            'content', NULL,
            'type', 'error',
            'message', 'Permission Denied: Only Ordinary user can update schedules'
        );
    END IF;

    -- Check if the schedule exists
    SELECT EXISTS (
        SELECT 1 FROM schedules
        WHERE schedule_id = p_schedule_id
    ) INTO schedule_exists;

    IF NOT schedule_exists THEN
        msg_type := 'error';
        msg_detail := 'Schedule with ID ' || p_schedule_id || ' does not exist!';
    ELSE
        -- Update the schedule
        UPDATE schedules
        SET
            date = p_date,
            departure_time = p_departure_time,
            arrival_time = p_arrival_time,
            destination = p_destination,
            plate_no = p_plate_no
        WHERE schedule_id = p_schedule_id;

        -- Fetch updated schedule record
        SELECT to_jsonb(p) INTO schedule_record
        FROM schedules p
        WHERE p.schedule_id = p_schedule_id;

        msg_type := 'success';
        msg_detail := 'Schedule ID ' || p_schedule_id || ' updated successfully!';
    END IF;

    -- Return the response in JSON format
    RETURN jsonb_build_object(
        'content', schedule_record,
        'type', msg_type,
        'message', msg_detail
    );
END;
$$;
 �   DROP FUNCTION public.fn_or_update_schedule(p_or_id integer, p_schedule_id integer, p_date date, p_plate_no character varying, p_departure_time time without time zone, p_arrival_time time without time zone, p_destination character varying);
       public               postgres    false            #           1255    34103 ^   pr_crud_penalties(integer, character varying, date, numeric, boolean, date, character varying) 	   PROCEDURE     q  CREATE PROCEDURE public.pr_crud_penalties(IN p_penalty_id integer DEFAULT NULL::integer, IN p_violation character varying DEFAULT NULL::character varying, IN p_violation_date date DEFAULT NULL::date, IN p_amount_penalty numeric DEFAULT NULL::numeric, IN p_paid boolean DEFAULT NULL::boolean, IN p_paid_date date DEFAULT NULL::date, IN p_or_no character varying DEFAULT NULL::character varying)
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
       public               postgres    false            $           1255    34104 p   pr_crud_schedule(character varying, timestamp without time zone, timestamp without time zone, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.pr_crud_schedule(IN p_plate_no character varying DEFAULT NULL::character varying, IN p_departure_time timestamp without time zone DEFAULT NULL::timestamp without time zone, IN p_arrival_time timestamp without time zone DEFAULT NULL::timestamp without time zone, IN p_destination character varying DEFAULT NULL::character varying)
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
       public               postgres    false            %           1255    34105 �   pr_crud_user(character varying, integer, character varying, character varying, character varying, character varying, character varying) 	   PROCEDURE     B  CREATE PROCEDURE public.pr_crud_user(IN operation_type character varying, IN p_user_id integer DEFAULT NULL::integer, IN p_username character varying DEFAULT NULL::character varying, IN p_password character varying DEFAULT NULL::character varying, IN p_fullname character varying DEFAULT NULL::character varying, IN p_usertype character varying DEFAULT NULL::character varying, IN p_plate_no character varying DEFAULT NULL::character varying)
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
       public               postgres    false            &           1255    34106 x   pr_deletevehicle(integer, character varying, character varying, character varying, character varying, character varying) 	   PROCEDURE     q  CREATE PROCEDURE public.pr_deletevehicle(IN p_capacity integer DEFAULT NULL::integer, IN p_categories character varying DEFAULT NULL::character varying, IN p_driver_name character varying DEFAULT NULL::character varying, IN p_contact_no character varying DEFAULT NULL::character varying, IN p_plate_no character varying DEFAULT NULL::character varying, IN p_vehicle_name character varying DEFAULT NULL::character varying)
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
       public               postgres    false            '           1255    34107 r   pr_vehicle(integer, character varying, character varying, character varying, character varying, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.pr_vehicle(IN p_capacity integer DEFAULT NULL::integer, IN p_categories character varying DEFAULT NULL::character varying, IN p_driver_name character varying DEFAULT NULL::character varying, IN p_contact_no character varying DEFAULT NULL::character varying, IN p_plate_no character varying DEFAULT NULL::character varying, IN p_vehicle_name character varying DEFAULT NULL::character varying)
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
       public               postgres    false            �            1259    34108 	   penalties    TABLE     1  CREATE TABLE public.penalties (
    penalty_id integer NOT NULL,
    violation character varying(100),
    violation_date date,
    amount_penalty numeric(10,2),
    paid boolean DEFAULT false,
    paid_date date,
    or_no character varying(20),
    plate_no character varying(8),
    user_id integer
);
    DROP TABLE public.penalties;
       public         heap r       postgres    false            �            1259    34112    penalties_penalty_id_seq    SEQUENCE     �   CREATE SEQUENCE public.penalties_penalty_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.penalties_penalty_id_seq;
       public               postgres    false    218            �           0    0    penalties_penalty_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.penalties_penalty_id_seq OWNED BY public.penalties.penalty_id;
          public               postgres    false    219            �            1259    34113 	   schedules    TABLE     �   CREATE TABLE public.schedules (
    schedule_id integer NOT NULL,
    departure_time time without time zone,
    arrival_time time without time zone,
    destination character varying(100),
    plate_no character varying(8),
    date date
);
    DROP TABLE public.schedules;
       public         heap r       postgres    false            �            1259    34116    schedules_schedule_id_seq    SEQUENCE     �   CREATE SEQUENCE public.schedules_schedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.schedules_schedule_id_seq;
       public               postgres    false    220            �           0    0    schedules_schedule_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.schedules_schedule_id_seq OWNED BY public.schedules.schedule_id;
          public               postgres    false    221            �            1259    34117    useraccounts    TABLE     �   CREATE TABLE public.useraccounts (
    user_id integer NOT NULL,
    username character varying NOT NULL,
    password text NOT NULL,
    plate_no character varying(8),
    fullname character varying,
    usertype character varying
);
     DROP TABLE public.useraccounts;
       public         heap r       postgres    false            �            1259    34122    useraccounts_user_id_seq    SEQUENCE     �   CREATE SEQUENCE public.useraccounts_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.useraccounts_user_id_seq;
       public               postgres    false    222            �           0    0    useraccounts_user_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.useraccounts_user_id_seq OWNED BY public.useraccounts.user_id;
          public               postgres    false    223            �            1259    34123    vehicles    TABLE       CREATE TABLE public.vehicles (
    plate_no character varying(8) NOT NULL,
    capacity integer,
    categories character varying(20),
    driver_name character varying(60),
    contact_no character varying(20),
    vehicle_name character varying(60),
    vehicle_id integer NOT NULL
);
    DROP TABLE public.vehicles;
       public         heap r       postgres    false            �            1259    34126    vehicles_vehicle_id_seq    SEQUENCE     �   CREATE SEQUENCE public.vehicles_vehicle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.vehicles_vehicle_id_seq;
       public               postgres    false    224            �           0    0    vehicles_vehicle_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.vehicles_vehicle_id_seq OWNED BY public.vehicles.vehicle_id;
          public               postgres    false    225            �            1259    34127    vw_schedule    VIEW     =  CREATE VIEW public.vw_schedule AS
 SELECT vehicles.plate_no,
    vehicles.categories,
    vehicles.driver_name,
    schedules.departure_time,
    schedules.arrival_time,
    schedules.destination
   FROM (public.schedules
     LEFT JOIN public.vehicles ON (((schedules.plate_no)::text = (vehicles.plate_no)::text)));
    DROP VIEW public.vw_schedule;
       public       v       postgres    false    220    220    220    220    224    224    224            �            1259    34131 
   vw_vehicle    VIEW     �   CREATE VIEW public.vw_vehicle AS
 SELECT driver_name,
    categories,
    capacity
   FROM public.vehicles
  WHERE ((categories)::text = 'Van'::text);
    DROP VIEW public.vw_vehicle;
       public       v       postgres    false    224    224    224            �           2604    34135    penalties penalty_id    DEFAULT     |   ALTER TABLE ONLY public.penalties ALTER COLUMN penalty_id SET DEFAULT nextval('public.penalties_penalty_id_seq'::regclass);
 C   ALTER TABLE public.penalties ALTER COLUMN penalty_id DROP DEFAULT;
       public               postgres    false    219    218            �           2604    34136    schedules schedule_id    DEFAULT     ~   ALTER TABLE ONLY public.schedules ALTER COLUMN schedule_id SET DEFAULT nextval('public.schedules_schedule_id_seq'::regclass);
 D   ALTER TABLE public.schedules ALTER COLUMN schedule_id DROP DEFAULT;
       public               postgres    false    221    220            �           2604    34137    useraccounts user_id    DEFAULT     |   ALTER TABLE ONLY public.useraccounts ALTER COLUMN user_id SET DEFAULT nextval('public.useraccounts_user_id_seq'::regclass);
 C   ALTER TABLE public.useraccounts ALTER COLUMN user_id DROP DEFAULT;
       public               postgres    false    223    222            �           2604    34138    vehicles vehicle_id    DEFAULT     z   ALTER TABLE ONLY public.vehicles ALTER COLUMN vehicle_id SET DEFAULT nextval('public.vehicles_vehicle_id_seq'::regclass);
 B   ALTER TABLE public.vehicles ALTER COLUMN vehicle_id DROP DEFAULT;
       public               postgres    false    225    224                      0    34108 	   penalties 
   TABLE DATA           �   COPY public.penalties (penalty_id, violation, violation_date, amount_penalty, paid, paid_date, or_no, plate_no, user_id) FROM stdin;
    public               postgres    false    218   R�       �          0    34113 	   schedules 
   TABLE DATA           k   COPY public.schedules (schedule_id, departure_time, arrival_time, destination, plate_no, date) FROM stdin;
    public               postgres    false    220   9�       �          0    34117    useraccounts 
   TABLE DATA           a   COPY public.useraccounts (user_id, username, password, plate_no, fullname, usertype) FROM stdin;
    public               postgres    false    222   �       �          0    34123    vehicles 
   TABLE DATA           u   COPY public.vehicles (plate_no, capacity, categories, driver_name, contact_no, vehicle_name, vehicle_id) FROM stdin;
    public               postgres    false    224   ��       �           0    0    penalties_penalty_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.penalties_penalty_id_seq', 10, true);
          public               postgres    false    219            �           0    0    schedules_schedule_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.schedules_schedule_id_seq', 10, true);
          public               postgres    false    221            �           0    0    useraccounts_user_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.useraccounts_user_id_seq', 23, true);
          public               postgres    false    223            �           0    0    vehicles_vehicle_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.vehicles_vehicle_id_seq', 9, true);
          public               postgres    false    225            �           2606    34140    penalties penalties_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.penalties
    ADD CONSTRAINT penalties_pkey PRIMARY KEY (penalty_id);
 B   ALTER TABLE ONLY public.penalties DROP CONSTRAINT penalties_pkey;
       public                 postgres    false    218            �           2606    34142    schedules schedules_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (schedule_id);
 B   ALTER TABLE ONLY public.schedules DROP CONSTRAINT schedules_pkey;
       public                 postgres    false    220            �           2606    34144    useraccounts useraccounts_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.useraccounts
    ADD CONSTRAINT useraccounts_pkey PRIMARY KEY (user_id);
 H   ALTER TABLE ONLY public.useraccounts DROP CONSTRAINT useraccounts_pkey;
       public                 postgres    false    222            �           2606    34146 &   useraccounts useraccounts_plate_no_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.useraccounts
    ADD CONSTRAINT useraccounts_plate_no_key UNIQUE (plate_no);
 P   ALTER TABLE ONLY public.useraccounts DROP CONSTRAINT useraccounts_plate_no_key;
       public                 postgres    false    222            �           2606    34148    vehicles vehicles_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (plate_no);
 @   ALTER TABLE ONLY public.vehicles DROP CONSTRAINT vehicles_pkey;
       public                 postgres    false    224            �           1259    34149    idx_user    INDEX     E   CREATE INDEX idx_user ON public.useraccounts USING btree (username);
    DROP INDEX public.idx_user;
       public                 postgres    false    222            �           1259    34150    idx_violation    INDEX     X   CREATE INDEX idx_violation ON public.penalties USING btree (violation, violation_date);
 !   DROP INDEX public.idx_violation;
       public                 postgres    false    218    218            �           2606    34151 !   penalties penalties_plate_no_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.penalties
    ADD CONSTRAINT penalties_plate_no_fkey FOREIGN KEY (plate_no) REFERENCES public.vehicles(plate_no);
 K   ALTER TABLE ONLY public.penalties DROP CONSTRAINT penalties_plate_no_fkey;
       public               postgres    false    224    218    4839            �           2606    34156     penalties penalties_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.penalties
    ADD CONSTRAINT penalties_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.useraccounts(user_id);
 J   ALTER TABLE ONLY public.penalties DROP CONSTRAINT penalties_user_id_fkey;
       public               postgres    false    4835    218    222            �           2606    34161 !   schedules schedules_plate_no_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_plate_no_fkey FOREIGN KEY (plate_no) REFERENCES public.vehicles(plate_no);
 K   ALTER TABLE ONLY public.schedules DROP CONSTRAINT schedules_plate_no_fkey;
       public               postgres    false    224    220    4839            �           2606    34166 '   useraccounts useraccounts_plate_no_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.useraccounts
    ADD CONSTRAINT useraccounts_plate_no_fkey FOREIGN KEY (plate_no) REFERENCES public.vehicles(plate_no);
 Q   ALTER TABLE ONLY public.useraccounts DROP CONSTRAINT useraccounts_plate_no_fkey;
       public               postgres    false    222    224    4839               �   x�}�MO1��3�����i��G�ㄻ.h�BtA�~?�E��h2��g����5��˲]�~�AH�e�"�D��.��ܗ&118�8�s�t67⼂G�����y�xС�xx4Fl?��ȫ%gI�������`�?��d)�Ew�F��7�l� �$�����p�߯���Y�C:��	����L�%�r����m���3�`��@�=[r`�      �   �   x�M�=�0Fg��@���4�F�E�.��!U�
��ۓ�TT����}�	PD_@h��T��`Q-9�\B�gH�Pi�Mm_vpwX�7|^*�P'	##�����v��kB
��Q8�+������E�
�Yɧ��yw���>6Pz��IV[�������)��Pe��`�v�O�{��˅V��3,Y;c�}�zAT      �   �  x�m�ٮ�Z�k�Sp��a�Re0��0,��A��?���;��,���U�J� �'H�v�ش�����~�0��js&U^�ҡN��:�����f�5����32��O�����������3L?C�5��L����u���Ё����$[�y5Z��+��?ǣ���,�>"�р?�$d�e~�G��3�jG��1�� ���?M�Gru ���h�c�]��٥��m=Nn:}��M���X��ԭQ[����_oHA�
��~_ߧ�Auʷ+�:D�tY�а�{�f-�4�~A-6�p��w(q��Ő@m鍵����2P��?�mimFJ����rZ(�K�j���2N>�Ơ"$��t�x8��^�vp�rfͦ�l��w�$~�o%���߫��('��sc��>=�酿A�O�����ౣi��L]�Su����7��f��TUaJr�0����H����lް�v�� `��a�^(�^�!z��8�f�D8���,����Z��s�8�oo��KW���bǪ;Ld�S�#GfJ�|��N��D��N����\���^��?����&x�-��No)�-*�G��#��nK�_�E�O�{����ʮ/�ܡk�_���l�w��� ����S}�PC�<�4 ���^�����α[η5�w$����1���AׄϡG���<f({���		��7�mJ&=R�bN��+�%Z|��ϰ��2҉!�,rڳ���1ݾ�?A����b�@�͹([]gR�m��M����r��#^��-C��ӛɷ�O��2���WN,�p��.��8'Q�"���d
��Y�>���Tpn����Q�����y68������?�tP��a����~?v.@�X�Mͽ�9�g R<�U��v��������� #��A      �   �   x�5��N�0��3O1O��$m|$)T���".�X���U�����,_�e���������Є~ �z�XV&;$���BJ��;z����kVH6��(||Z��"�K����;�/���'u���7-1wFl§'���7���)l�m&���N�P�4�@����T�/���q����/�����|�R'
+
�V�u�9%l�+T�)�8b�D� SQ�     