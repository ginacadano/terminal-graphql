PGDMP                      }            terminal    17.2    17.2 J    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            �           1262    33913    terminal    DATABASE     �   CREATE DATABASE terminal WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_Philippines.1252';
    DROP DATABASE terminal;
                     postgres    false                        3079    33914    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                        false            �           0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                             false    2                       1255    33951 R   fn_admin_add_penalty(integer, character varying, date, numeric, character varying)    FUNCTION     �	  CREATE FUNCTION public.fn_admin_add_penalty(p_admin_id integer, p_violation character varying, p_violation_date date, p_amount_penalty numeric, p_plate_no character varying) RETURNS jsonb
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
       public               postgres    false                       1255    33952 M   fn_admin_add_useraccount(integer, character varying, text, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_admin_add_useraccount(p_admin_id integer, p_username character varying, p_password text, p_usertype character varying) RETURNS jsonb
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
       public               postgres    false                       1255    33953 �   fn_admin_add_vehicle(integer, integer, character varying, character varying, character varying, character varying, character varying)    FUNCTION     �
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
       public               postgres    false                       1255    33954 -   fn_admin_delete_useraccount(integer, integer)    FUNCTION     X  CREATE FUNCTION public.fn_admin_delete_useraccount(p_admin_id integer, p_user_id integer) RETURNS jsonb
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
       public               postgres    false                       1255    33955 ^   fn_admin_update_penalty(integer, integer, character varying, date, numeric, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_admin_update_penalty(p_admin_id integer, p_penalty_id integer, p_violation character varying, p_violation_date date, p_amount_penalty numeric, p_plate_no character varying) RETURNS jsonb
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
       public               postgres    false                       1255    33956 Y   fn_admin_update_useraccount(integer, integer, character varying, text, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_admin_update_useraccount(p_admin_id integer, p_user_id integer, p_username character varying, p_password text, p_usertype character varying) RETURNS jsonb
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
       public               postgres    false            (           1255    34046 �   fn_admin_update_vehicle(integer, integer, character varying, integer, character varying, character varying, character varying, character varying)    FUNCTION     /	  CREATE FUNCTION public.fn_admin_update_vehicle(p_admin_id integer, p_vehicle_id integer, p_plate_no character varying, p_capacity integer, p_categories character varying, p_driver_name character varying, p_contact_no character varying, p_vehicle_name character varying) RETURNS jsonb
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
       public               postgres    false                       1255    33959 O   fn_create_penalty(integer, character varying, date, numeric, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_create_penalty(p_user_id integer, p_violation character varying, p_violation_date date, p_amount_penalty numeric, p_plate_no character varying) RETURNS void
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
       public               postgres    false                       1255    33960 �   fn_create_vehicle(character varying, integer, character varying, character varying, character varying, character varying, character varying)    FUNCTION       CREATE FUNCTION public.fn_create_vehicle(p_usertype character varying, p_capacity integer DEFAULT NULL::integer, p_categories character varying DEFAULT NULL::character varying, p_driver_name character varying DEFAULT NULL::character varying, p_contact_no character varying DEFAULT NULL::character varying, p_plate_no character varying DEFAULT NULL::character varying, p_vehicle_name character varying DEFAULT NULL::character varying) RETURNS void
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
       public               postgres    false                       1255    33961 �   fn_crud_user(character varying, integer, character varying, character varying, character varying, character varying, character varying)    FUNCTION     h  CREATE FUNCTION public.fn_crud_user(p_operation_type character varying, p_user_id integer DEFAULT NULL::integer, p_username character varying DEFAULT NULL::character varying, p_password character varying DEFAULT NULL::character varying, p_fullname character varying DEFAULT NULL::character varying, p_usertype character varying DEFAULT NULL::character varying, p_plate_no character varying DEFAULT NULL::character varying) RETURNS void
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
       public               postgres    false                       1255    33962 %   fn_delete_schedule(character varying)    FUNCTION       CREATE FUNCTION public.fn_delete_schedule(p_plate_no character varying) RETURNS void
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
       public               postgres    false                       1255    33963    fn_delete_user(integer)    FUNCTION     �   CREATE FUNCTION public.fn_delete_user(p_user_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
IF p_usertype = 'admin' THEN
    DELETE FROM useraccounts WHERE user_id = p_user_id;
	END IF;
END;
$$;
 8   DROP FUNCTION public.fn_delete_user(p_user_id integer);
       public               postgres    false                       1255    33964 �   fn_delete_vehicle(character varying, character varying, integer, character varying, character varying, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_delete_vehicle(p_usertype character varying, p_operation_type character varying, p_capacity integer DEFAULT NULL::integer, p_categories character varying DEFAULT NULL::character varying, p_driver_name character varying DEFAULT NULL::character varying, p_contact_no character varying DEFAULT NULL::character varying, p_plate_no character varying DEFAULT NULL::character varying, p_vehicle_name character varying DEFAULT NULL::character varying) RETURNS void
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
       public               postgres    false                        1255    33965 b   fn_insert_penalty(character varying, date, numeric, character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.fn_insert_penalty(p_violation character varying, p_violation_date date, p_penalty_amount numeric, p_plate_no character varying, p_created_by character varying, p_user_id integer) RETURNS jsonb
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
       public               postgres    false            !           1255    33966 r   fn_insert_schedule(character varying, timestamp without time zone, timestamp without time zone, character varying)    FUNCTION     w  CREATE FUNCTION public.fn_insert_schedule(p_plate_no character varying, p_departure_time timestamp without time zone, p_arrival_time timestamp without time zone, p_destination character varying) RETURNS jsonb
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
       public               postgres    false            "           1255    33967 m   fn_insert_user(character varying, character varying, character varying, character varying, character varying)    FUNCTION       CREATE FUNCTION public.fn_insert_user(p_username character varying, p_password character varying, p_fullname character varying, p_usertype character varying, p_operation character varying) RETURNS jsonb
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
       public               postgres    false                       1255    33968    fn_login(character varying)    FUNCTION     �  CREATE FUNCTION public.fn_login(p_username character varying) RETURNS jsonb
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
       public               postgres    false            #           1255    33969 9   fn_mark_penalty_as_paid(integer, date, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_mark_penalty_as_paid(p_penalty_id integer, p_paid_date date, p_or_no character varying) RETURNS jsonb
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
       public               postgres    false            $           1255    33970 �   fn_o_user_add_schedule(integer, date, character varying, timestamp without time zone, timestamp without time zone, character varying)    FUNCTION     (  CREATE FUNCTION public.fn_o_user_add_schedule(p_or_id integer, p_date date, p_plate_no character varying, p_departure_time timestamp without time zone, p_arrival_time timestamp without time zone, p_destination character varying) RETURNS jsonb
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
            'message', 'Ordinary user not found'
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
        WHERE date = p_date
        AND departure_time = p_departure_time
        AND arrival_time = p_arrival_time
		AND destination = p_destination 
		AND plate_no = p_plate_no
    ) INTO schedule_exists;

    IF NOT schedule_exists THEN
        -- Insert new schedule and return the generated schedule_id
        INSERT INTO schedules (date, departure_time, arrival_time, destination, plate_no)
    VALUES (p_date, p_departure_time, p_arrival_time, p_destination, p_plate_no)
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
 �   DROP FUNCTION public.fn_o_user_add_schedule(p_or_id integer, p_date date, p_plate_no character varying, p_departure_time timestamp without time zone, p_arrival_time timestamp without time zone, p_destination character varying);
       public               postgres    false            %           1255    33971 w   fn_or_add_schedule(integer, date, character varying, time without time zone, time without time zone, character varying)    FUNCTION     o  CREATE FUNCTION public.fn_or_add_schedule(p_or_id integer, p_date date, p_plate_no character varying, p_departure_time time without time zone, p_arrival_time time without time zone, p_destination character varying) RETURNS jsonb
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
       public               postgres    false            &           1255    33972 '   fn_or_delete_schedule(integer, integer)    FUNCTION       CREATE FUNCTION public.fn_or_delete_schedule(p_or_id integer, p_schedule_id integer) RETURNS jsonb
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
       public               postgres    false            '           1255    33973 �   fn_or_update_schedule(integer, integer, date, character varying, time without time zone, time without time zone, character varying)    FUNCTION     U  CREATE FUNCTION public.fn_or_update_schedule(p_or_id integer, p_schedule_id integer, p_date date, p_plate_no character varying, p_departure_time time without time zone, p_arrival_time time without time zone, p_destination character varying) RETURNS jsonb
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
       public               postgres    false            )           1255    33974 b   fn_update_penalty(integer, character varying, date, numeric, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_update_penalty(p_penalty_id integer, p_violation character varying, p_violation_date date, p_penalty_amount numeric, p_plate_no character varying, p_usertype character varying) RETURNS jsonb
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
       public               postgres    false            *           1255    33975 r   fn_update_schedule(character varying, timestamp without time zone, timestamp without time zone, character varying)    FUNCTION     Z  CREATE FUNCTION public.fn_update_schedule(p_plate_no character varying, p_departure_time timestamp without time zone, p_arrival_time timestamp without time zone, p_destination character varying) RETURNS void
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
       public               postgres    false            +           1255    33976 m   fn_update_user(character varying, character varying, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_update_user(p_username character varying, p_password character varying, p_fullname character varying, p_usertype character varying, p_operation character varying) RETURNS jsonb
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
       public               postgres    false            ,           1255    33977 �   fn_update_vehicle(character varying, character varying, integer, character varying, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_update_vehicle(p_usertype character varying, p_plate_no character varying, p_capacity integer DEFAULT NULL::integer, p_categories character varying DEFAULT NULL::character varying, p_driver_name character varying DEFAULT NULL::character varying, p_contact_no character varying DEFAULT NULL::character varying, p_vehicle_name character varying DEFAULT NULL::character varying) RETURNS void
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
       public               postgres    false            -           1255    33978 ^   pr_crud_penalties(integer, character varying, date, numeric, boolean, date, character varying) 	   PROCEDURE     q  CREATE PROCEDURE public.pr_crud_penalties(IN p_penalty_id integer DEFAULT NULL::integer, IN p_violation character varying DEFAULT NULL::character varying, IN p_violation_date date DEFAULT NULL::date, IN p_amount_penalty numeric DEFAULT NULL::numeric, IN p_paid boolean DEFAULT NULL::boolean, IN p_paid_date date DEFAULT NULL::date, IN p_or_no character varying DEFAULT NULL::character varying)
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
       public               postgres    false            .           1255    33979 p   pr_crud_schedule(character varying, timestamp without time zone, timestamp without time zone, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.pr_crud_schedule(IN p_plate_no character varying DEFAULT NULL::character varying, IN p_departure_time timestamp without time zone DEFAULT NULL::timestamp without time zone, IN p_arrival_time timestamp without time zone DEFAULT NULL::timestamp without time zone, IN p_destination character varying DEFAULT NULL::character varying)
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
       public               postgres    false            /           1255    33980 �   pr_crud_user(character varying, integer, character varying, character varying, character varying, character varying, character varying) 	   PROCEDURE     B  CREATE PROCEDURE public.pr_crud_user(IN operation_type character varying, IN p_user_id integer DEFAULT NULL::integer, IN p_username character varying DEFAULT NULL::character varying, IN p_password character varying DEFAULT NULL::character varying, IN p_fullname character varying DEFAULT NULL::character varying, IN p_usertype character varying DEFAULT NULL::character varying, IN p_plate_no character varying DEFAULT NULL::character varying)
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
       public               postgres    false            0           1255    33981 x   pr_deletevehicle(integer, character varying, character varying, character varying, character varying, character varying) 	   PROCEDURE     q  CREATE PROCEDURE public.pr_deletevehicle(IN p_capacity integer DEFAULT NULL::integer, IN p_categories character varying DEFAULT NULL::character varying, IN p_driver_name character varying DEFAULT NULL::character varying, IN p_contact_no character varying DEFAULT NULL::character varying, IN p_plate_no character varying DEFAULT NULL::character varying, IN p_vehicle_name character varying DEFAULT NULL::character varying)
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
       public               postgres    false            1           1255    33982 r   pr_vehicle(integer, character varying, character varying, character varying, character varying, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.pr_vehicle(IN p_capacity integer DEFAULT NULL::integer, IN p_categories character varying DEFAULT NULL::character varying, IN p_driver_name character varying DEFAULT NULL::character varying, IN p_contact_no character varying DEFAULT NULL::character varying, IN p_plate_no character varying DEFAULT NULL::character varying, IN p_vehicle_name character varying DEFAULT NULL::character varying)
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
       public               postgres    false            �            1259    33983 	   penalties    TABLE     1  CREATE TABLE public.penalties (
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
       public         heap r       postgres    false            �            1259    33987    penalties_penalty_id_seq    SEQUENCE     �   CREATE SEQUENCE public.penalties_penalty_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.penalties_penalty_id_seq;
       public               postgres    false    218            �           0    0    penalties_penalty_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.penalties_penalty_id_seq OWNED BY public.penalties.penalty_id;
          public               postgres    false    219            �            1259    33988 	   schedules    TABLE     �   CREATE TABLE public.schedules (
    schedule_id integer NOT NULL,
    departure_time time without time zone,
    arrival_time time without time zone,
    destination character varying(100),
    plate_no character varying(8),
    date date
);
    DROP TABLE public.schedules;
       public         heap r       postgres    false            �            1259    33991    schedules_schedule_id_seq    SEQUENCE     �   CREATE SEQUENCE public.schedules_schedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.schedules_schedule_id_seq;
       public               postgres    false    220            �           0    0    schedules_schedule_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.schedules_schedule_id_seq OWNED BY public.schedules.schedule_id;
          public               postgres    false    221            �            1259    33992    useraccounts    TABLE     �   CREATE TABLE public.useraccounts (
    user_id integer NOT NULL,
    username character varying NOT NULL,
    password text NOT NULL,
    plate_no character varying(8),
    fullname character varying,
    usertype character varying
);
     DROP TABLE public.useraccounts;
       public         heap r       postgres    false            �            1259    33997    useraccounts_user_id_seq    SEQUENCE     �   CREATE SEQUENCE public.useraccounts_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.useraccounts_user_id_seq;
       public               postgres    false    222            �           0    0    useraccounts_user_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.useraccounts_user_id_seq OWNED BY public.useraccounts.user_id;
          public               postgres    false    223            �            1259    33998    vehicles    TABLE       CREATE TABLE public.vehicles (
    plate_no character varying(8) NOT NULL,
    capacity integer,
    categories character varying(20),
    driver_name character varying(60),
    contact_no character varying(20),
    vehicle_name character varying(60),
    vehicle_id integer NOT NULL
);
    DROP TABLE public.vehicles;
       public         heap r       postgres    false            �            1259    34001    vehicles_vehicle_id_seq    SEQUENCE     �   CREATE SEQUENCE public.vehicles_vehicle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.vehicles_vehicle_id_seq;
       public               postgres    false    224            �           0    0    vehicles_vehicle_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.vehicles_vehicle_id_seq OWNED BY public.vehicles.vehicle_id;
          public               postgres    false    225            �            1259    34002    vw_schedule    VIEW     =  CREATE VIEW public.vw_schedule AS
 SELECT vehicles.plate_no,
    vehicles.categories,
    vehicles.driver_name,
    schedules.departure_time,
    schedules.arrival_time,
    schedules.destination
   FROM (public.schedules
     LEFT JOIN public.vehicles ON (((schedules.plate_no)::text = (vehicles.plate_no)::text)));
    DROP VIEW public.vw_schedule;
       public       v       postgres    false    224    224    220    220    220    220    224            �            1259    34006 
   vw_vehicle    VIEW     �   CREATE VIEW public.vw_vehicle AS
 SELECT driver_name,
    categories,
    capacity
   FROM public.vehicles
  WHERE ((categories)::text = 'Van'::text);
    DROP VIEW public.vw_vehicle;
       public       v       postgres    false    224    224    224            �           2604    34010    penalties penalty_id    DEFAULT     |   ALTER TABLE ONLY public.penalties ALTER COLUMN penalty_id SET DEFAULT nextval('public.penalties_penalty_id_seq'::regclass);
 C   ALTER TABLE public.penalties ALTER COLUMN penalty_id DROP DEFAULT;
       public               postgres    false    219    218            �           2604    34011    schedules schedule_id    DEFAULT     ~   ALTER TABLE ONLY public.schedules ALTER COLUMN schedule_id SET DEFAULT nextval('public.schedules_schedule_id_seq'::regclass);
 D   ALTER TABLE public.schedules ALTER COLUMN schedule_id DROP DEFAULT;
       public               postgres    false    221    220            �           2604    34012    useraccounts user_id    DEFAULT     |   ALTER TABLE ONLY public.useraccounts ALTER COLUMN user_id SET DEFAULT nextval('public.useraccounts_user_id_seq'::regclass);
 C   ALTER TABLE public.useraccounts ALTER COLUMN user_id DROP DEFAULT;
       public               postgres    false    223    222            �           2604    34013    vehicles vehicle_id    DEFAULT     z   ALTER TABLE ONLY public.vehicles ALTER COLUMN vehicle_id SET DEFAULT nextval('public.vehicles_vehicle_id_seq'::regclass);
 B   ALTER TABLE public.vehicles ALTER COLUMN vehicle_id DROP DEFAULT;
       public               postgres    false    225    224            �          0    33983 	   penalties 
   TABLE DATA           �   COPY public.penalties (penalty_id, violation, violation_date, amount_penalty, paid, paid_date, or_no, plate_no, user_id) FROM stdin;
    public               postgres    false    218   4      �          0    33988 	   schedules 
   TABLE DATA           k   COPY public.schedules (schedule_id, departure_time, arrival_time, destination, plate_no, date) FROM stdin;
    public               postgres    false    220         �          0    33992    useraccounts 
   TABLE DATA           a   COPY public.useraccounts (user_id, username, password, plate_no, fullname, usertype) FROM stdin;
    public               postgres    false    222   �      �          0    33998    vehicles 
   TABLE DATA           u   COPY public.vehicles (plate_no, capacity, categories, driver_name, contact_no, vehicle_name, vehicle_id) FROM stdin;
    public               postgres    false    224         �           0    0    penalties_penalty_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.penalties_penalty_id_seq', 10, true);
          public               postgres    false    219            �           0    0    schedules_schedule_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.schedules_schedule_id_seq', 9, true);
          public               postgres    false    221            �           0    0    useraccounts_user_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.useraccounts_user_id_seq', 21, true);
          public               postgres    false    223            �           0    0    vehicles_vehicle_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.vehicles_vehicle_id_seq', 9, true);
          public               postgres    false    225            �           2606    34015    penalties penalties_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.penalties
    ADD CONSTRAINT penalties_pkey PRIMARY KEY (penalty_id);
 B   ALTER TABLE ONLY public.penalties DROP CONSTRAINT penalties_pkey;
       public                 postgres    false    218            �           2606    34017    schedules schedules_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (schedule_id);
 B   ALTER TABLE ONLY public.schedules DROP CONSTRAINT schedules_pkey;
       public                 postgres    false    220            �           2606    34019    useraccounts useraccounts_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.useraccounts
    ADD CONSTRAINT useraccounts_pkey PRIMARY KEY (user_id);
 H   ALTER TABLE ONLY public.useraccounts DROP CONSTRAINT useraccounts_pkey;
       public                 postgres    false    222            �           2606    34021 &   useraccounts useraccounts_plate_no_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.useraccounts
    ADD CONSTRAINT useraccounts_plate_no_key UNIQUE (plate_no);
 P   ALTER TABLE ONLY public.useraccounts DROP CONSTRAINT useraccounts_plate_no_key;
       public                 postgres    false    222            �           2606    34023    vehicles vehicles_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (plate_no);
 @   ALTER TABLE ONLY public.vehicles DROP CONSTRAINT vehicles_pkey;
       public                 postgres    false    224            �           1259    34024    idx_user    INDEX     E   CREATE INDEX idx_user ON public.useraccounts USING btree (username);
    DROP INDEX public.idx_user;
       public                 postgres    false    222            �           1259    34025    idx_violation    INDEX     X   CREATE INDEX idx_violation ON public.penalties USING btree (violation, violation_date);
 !   DROP INDEX public.idx_violation;
       public                 postgres    false    218    218            �           2606    34026 !   penalties penalties_plate_no_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.penalties
    ADD CONSTRAINT penalties_plate_no_fkey FOREIGN KEY (plate_no) REFERENCES public.vehicles(plate_no);
 K   ALTER TABLE ONLY public.penalties DROP CONSTRAINT penalties_plate_no_fkey;
       public               postgres    false    218    4849    224            �           2606    34031     penalties penalties_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.penalties
    ADD CONSTRAINT penalties_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.useraccounts(user_id);
 J   ALTER TABLE ONLY public.penalties DROP CONSTRAINT penalties_user_id_fkey;
       public               postgres    false    4845    222    218            �           2606    34036 !   schedules schedules_plate_no_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_plate_no_fkey FOREIGN KEY (plate_no) REFERENCES public.vehicles(plate_no);
 K   ALTER TABLE ONLY public.schedules DROP CONSTRAINT schedules_plate_no_fkey;
       public               postgres    false    4849    220    224            �           2606    34041 '   useraccounts useraccounts_plate_no_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.useraccounts
    ADD CONSTRAINT useraccounts_plate_no_fkey FOREIGN KEY (plate_no) REFERENCES public.vehicles(plate_no);
 Q   ALTER TABLE ONLY public.useraccounts DROP CONSTRAINT useraccounts_plate_no_fkey;
       public               postgres    false    4849    224    222            �   �   x�}�MO1��3�����i��G�ㄻ.h�BtA�~?�E��h2��g����5��˲]�~�AH�e�"�D��.��ܗ&118�8�s�t67⼂G�����y�xС�xx4Fl?��ȫ%gI�������`�?��d)�Ew�F��7�l� �$�����p�߯���Y�C:��	����L�%�r����m���3�`��@�=[r`�      �   �   x�M��
�@뽧�0�g��4?��Bb�����+4�oONl��K�I����:r�,d�A�
5ԥP@z��"7
���8��r'�q!��R�^�K�ۡ�#\�RBr��M��s���v�䒍������ok��x�d�de���e��Aִ���BeL4��	!~#�7      �   6  x�m�ٮ�Z�k|
.�m\�r	��� ���ð�Adx����}b�H*�WU�(0l�
'H���uWV��DtzS�eT�P����<-fb��-��H�
6�JZ����T�"m�'hD�dX$ލ�;������)���TI�ж�ՌB�(�+�y5j+��F��N��_E��2�@�j��<�i��!C �V̀���p���
m����J.�:�p�`Ns��^tf�L/X�r8������r�w��U|WWFanw��vɓ�^�(��=�2�%�ޮ��1��پai��)�8�,���d�?=�6%�C�, �͛���~�\����L��uR�ȑ��t+�G������0���HK{'�aiP\T��~x8�$���s���PX���"�	E�-%;�����ﰠ���5�_G�����k��kηv�������'X����HL����>l!w�"�=���קP��1���@F�M^�H�࡭i�����*��)�v�ˍn�[ZPy6ѵ\1�{Pf�?+������N��i�/YN�`z��8c��ȇ�x<�`�*���d��������:M�ߜ��jL���]��Vܦ�c��L�Ե=a-)y�\�������蚯��Y�Q����w?k݇�����fɢ�<�X�(�qs����^`�s�[n���E3�5��3� ��G;;7��*|���Ѡl�>@����yB1$V�ki 4kR��D�o��7��^,	�[�E��Ӑ����?'$�ߠ�gL��(��%W�8�`t��\�=G���&�]��4�P��Ԕ����f��O�X      �     x�5��N�0D����y�b'�"&�����R{����v�!r�]U��]yM��)�jc.P����`�Y^(78�nni�c�`X��O��Q�jP-��/�����9�>1���-���<�EF� I-E�8�w3δ���QpI�;FRJ�_^)�@0(�	�@����}�mM��1����BC�V�C��B�E*�O���tn������T/�:%Q��J��A�dkܝE��R�p6ޝA����Ty�i�)>\!C/�����k=fP     