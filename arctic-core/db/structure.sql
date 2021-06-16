SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: dispersal_states; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.dispersal_states AS ENUM (
    'pending',
    'inprogress',
    'completed',
    'failed'
);


--
-- Name: product_error_severity; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.product_error_severity AS ENUM (
    'error',
    'warning'
);


--
-- Name: dispersals_updated_function(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dispersals_updated_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
              BEGIN
                UPDATE products_list
                SET last_synced_at = NEW.updated_at,
                    dispersal_state = NEW.state,
                    updated_at = now()
                WHERE products_list.vendor_shop_configuration_id = NEW.vendor_shop_configuration_id
                AND products_list.sku = NEW.product_id
                AND products_list.deleted_at IS NULL;

                RETURN NEW;
              END
            $$;


--
-- Name: products_updated_function(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.products_updated_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
              BEGIN
                IF (TG_OP = 'DELETE') THEN
                  DELETE FROM products_list
                  WHERE products_list.sku = NEW.sku;
                ELSE
                  UPDATE products_list
                  SET name = COALESCE(
                        (
                          SELECT name
                          FROM shadow_products
                          WHERE shadow_products.vendor_shop_configuration_id = products_list.vendor_shop_configuration_id
                            AND shadow_products.product_id = NEW.sku
                            AND shadow_products.deleted_at IS NULL
                        ),
                        NEW.name
                      ),
                      ean = COALESCE(
                        (
                          SELECT ean
                          FROM shadow_products
                          WHERE shadow_products.vendor_shop_configuration_id = products_list.vendor_shop_configuration_id
                            AND shadow_products.product_id = NEW.sku
                            AND shadow_products.deleted_at IS NULL
                        ),
                        NEW.ean
                      ),
                      sku = COALESCE(
                        (
                          SELECT product_id
                          FROM shadow_products
                          WHERE shadow_products.vendor_shop_configuration_id = products_list.vendor_shop_configuration_id
                            AND shadow_products.product_id = NEW.sku
                            AND shadow_products.deleted_at IS NULL
                        ),
                        NEW.sku
                      ),
                      updated_at = now()
                  WHERE products_list.sku = NEW.sku
                    AND products_list.deleted_at IS NULL;
                END IF;

                RETURN NEW;
              END
            $$;


--
-- Name: shadow_products_updated_function(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.shadow_products_updated_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
          BEGIN
            IF (TG_OP = 'DELETE') THEN
              DELETE FROM products_list
              WHERE products_list.shadow_product_id = NEW.id;
            ELSE
              WITH upsert AS (
                UPDATE products_list
                  SET vendor_shop_configuration_id = NEW.vendor_shop_configuration_id,
                      shadow_product_id = NEW.id,
                      sku = COALESCE(
                        NEW.sku,
                        NEW.product_id
                      ),
                      master_sku = (
                        SELECT master_sku FROM products
                        WHERE products.sku = NEW.product_id
                          AND products.deleted_at IS NULL
                      ),
                      shop_id = (
                        SELECT shop_id FROM products
                        WHERE products.sku = NEW.product_id
                          AND products.deleted_at IS NULL
                      ),
                      name = COALESCE(
                        NEW.name,
                        (
                          SELECT name FROM products
                          WHERE products.sku = NEW.product_id
                          AND products.deleted_at IS NULL
                        )
                      ),
                      product_error_count = (
                        SELECT count(*) FROM product_errors
                        WHERE product_errors.shadow_product_id = NEW.id
                          AND product_errors.severity = 'error'
                          AND product_errors.deleted_at IS NULL
                      ),
                      ean = COALESCE(
                        NEW.ean,
                        (
                          SELECT ean FROM products
                          WHERE products.sku = NEW.product_id
                          AND products.deleted_at IS NULL
                        )
                      ),
                      match_error_count = (
                        SELECT count(*) FROM vendor_product_matches
                        WHERE vendor_product_matches.product_id = NEW.product_id
                          AND vendor_product_matches.vendor_shop_configuration_id = NEW.vendor_shop_configuration_id
                          AND vendor_product_matches.matched = FALSE
                          AND vendor_product_matches.deleted_at IS NULL
                      ),
                      last_synced_at = (
                        SELECT updated_at FROM dispersals
                        WHERE dispersals.product_id = NEW.product_id
                          AND dispersals.vendor_shop_configuration_id = NEW.vendor_shop_configuration_id
                          AND dispersals.state = 'completed'
                          AND dispersals.deleted_at IS NULL
                      ),
                      dispersal_state = (
                        SELECT state FROM dispersals
                        WHERE dispersals.product_id = NEW.product_id
                          AND dispersals.vendor_shop_configuration_id = NEW.vendor_shop_configuration_id
                          AND dispersals.deleted_at IS NULL
                        ORDER BY dispersals.updated_at DESC
                        LIMIT 1
                      ),
                      deleted_at = NEW.deleted_at,
                      updated_at = now()
                  WHERE products_list.vendor_shop_configuration_id::UUID = NEW.vendor_shop_configuration_id::UUID
                    AND products_list.sku = NEW.product_id
                RETURNING *)

              INSERT INTO products_list (
                shadow_product_id,
                sku,
                vendor_shop_configuration_id,
                deleted_at,
                master_sku,
                shop_id,
                ean,
                name,
                product_error_count,
                match_error_count,
                dispersal_state,
                last_synced_at,
                created_at,
                updated_at
              ) SELECT
                NEW.id,
                NEW.product_id,
                NEW.vendor_shop_configuration_id,
                NEW.deleted_at,
                (
                  SELECT master_sku FROM products
                  WHERE products.sku = NEW.product_id
                    AND products.deleted_at IS NULL
                ),
                (
                  SELECT shop_id FROM products
                  WHERE products.sku = NEW.product_id
                    AND products.deleted_at IS NULL
                ),
                COALESCE(
                  NEW.ean,
                  (
                    SELECT ean FROM products
                    WHERE products.sku = NEW.product_id
                      AND products.deleted_at IS NULL
                  )
                ),
                COALESCE(NEW.name, (SELECT name from products where products.sku = NEW.product_id)),
                (
                  SELECT count(*) FROM product_errors
                  WHERE product_errors.shadow_product_id = NEW.id
                    AND product_errors.severity = 'error'
                    AND product_errors.deleted_at IS NULL
                ),
                (
                  SELECT count(*) FROM vendor_product_matches
                  WHERE vendor_product_matches.product_id = NEW.product_id
                    AND vendor_product_matches.vendor_shop_configuration_id = NEW.vendor_shop_configuration_id
                    AND vendor_product_matches.matched = FALSE
                    AND vendor_product_matches.deleted_at IS NULL
                ),
                (
                  SELECT state FROM dispersals
                  WHERE dispersals.product_id = NEW.product_id
                    AND dispersals.vendor_shop_configuration_id = NEW.vendor_shop_configuration_id
                    AND dispersals.deleted_at IS NULL
                  ORDER BY dispersals.updated_at DESC
                  LIMIT 1
                ),
                (
                  SELECT updated_at FROM dispersals
                  WHERE dispersals.product_id = NEW.product_id
                    AND dispersals.vendor_shop_configuration_id = NEW.vendor_shop_configuration_id
                    AND dispersals.state = 'completed'
                    AND dispersals.deleted_at IS NULL
                ),
                now(),
                now()
              WHERE NOT EXISTS (SELECT * FROM upsert);
            END IF;

            RETURN NEW;
          END
        $$;


--
-- Name: vendor_product_matches_updated_function(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vendor_product_matches_updated_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
              BEGIN
                UPDATE products_list
                SET match_error_count = (
                      SELECT count(*)
                      FROM vendor_product_matches
                      WHERE vendor_product_matches.vendor_shop_configuration_id = NEW.vendor_shop_configuration_id
                        AND vendor_product_matches.product_id = NEW.product_id
                        AND vendor_product_matches.matched IS FALSE
                        AND vendor_product_matches.deleted_at IS NULL
                    ),
                    updated_at = now()
                WHERE products_list.vendor_shop_configuration_id = NEW.vendor_shop_configuration_id
                  AND products_list.sku = NEW.product_id
                  AND products_list.deleted_at IS NULL;

                RETURN NEW;
              END
            $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_id uuid NOT NULL,
    record_type character varying NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addresses (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    address1 character varying NOT NULL,
    address2 character varying,
    zip character varying NOT NULL,
    country character varying NOT NULL,
    city character varying NOT NULL,
    region character varying,
    phone character varying,
    email character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: category_maps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.category_maps (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    vendor_shop_configuration_id uuid NOT NULL,
    source character varying NOT NULL,
    value json DEFAULT '{}'::json NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    name character varying,
    "position" integer DEFAULT 0 NOT NULL
);


--
-- Name: channels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.channels (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    auth_config_schema json DEFAULT '{}'::json NOT NULL,
    category_map_json_schema json DEFAULT '{}'::json NOT NULL,
    config_schema json DEFAULT '{}'::json NOT NULL
);


--
-- Name: currency_conversions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.currency_conversions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    shop_id uuid NOT NULL,
    from_currency character varying NOT NULL,
    to_currency character varying NOT NULL,
    rate double precision NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: dispersals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dispersals (
    product_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    state public.dispersal_states DEFAULT 'pending'::public.dispersal_states NOT NULL,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    vendor_shop_configuration_id uuid NOT NULL
);


--
-- Name: import_maps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.import_maps (
    id bigint NOT NULL,
    vendor_shop_configuration_id uuid,
    "from" character varying NOT NULL,
    "to" character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    "position" integer DEFAULT 0 NOT NULL,
    "default" character varying,
    regex character varying
);


--
-- Name: import_maps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.import_maps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: import_maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.import_maps_id_seq OWNED BY public.import_maps.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_grants (
    id bigint NOT NULL,
    resource_owner_id uuid NOT NULL,
    application_id bigint NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying
);


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_access_grants_id_seq OWNED BY public.oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_tokens (
    id bigint NOT NULL,
    resource_owner_id uuid,
    application_id bigint,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying,
    previous_refresh_token character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_access_tokens_id_seq OWNED BY public.oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_applications (
    id bigint NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    confidential boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_applications_id_seq OWNED BY public.oauth_applications.id;


--
-- Name: order_invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_invoices (
    order_id uuid,
    invoice_id character varying,
    status character varying,
    cents integer,
    currency character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    order_lines json DEFAULT '[]'::json NOT NULL,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL
);


--
-- Name: order_lines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_lines (
    line_id character varying,
    product_id uuid NOT NULL,
    quantity integer DEFAULT 0 NOT NULL,
    track_and_trace_reference character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    status integer DEFAULT 0 NOT NULL,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    order_id uuid,
    cents_without_vat integer,
    cents_with_vat integer
);


--
-- Name: order_raw_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_raw_data (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    order_id character varying NOT NULL,
    data json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    shop_id uuid NOT NULL,
    order_id character varying NOT NULL,
    delivery_address_id uuid NOT NULL,
    billing_address_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    currency character varying DEFAULT 'DKK'::character varying NOT NULL,
    payment_reference character varying,
    purchased_at timestamp without time zone,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    vendor_id uuid NOT NULL,
    order_receipt_id character varying,
    vat double precision DEFAULT 25.0 NOT NULL,
    shipping_fee integer DEFAULT 0 NOT NULL,
    payment_fee integer DEFAULT 0 NOT NULL,
    shipping_method_id uuid,
    shipping_carrier_id uuid
);


--
-- Name: product_errors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_errors (
    message character varying NOT NULL,
    details text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    severity public.product_error_severity DEFAULT 'error'::public.product_error_severity NOT NULL,
    raw_data jsonb,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    shadow_product_id uuid
);


--
-- Name: product_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_images (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    url character varying NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    product_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: product_prices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_prices (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    cents integer NOT NULL,
    currency character varying NOT NULL,
    expires_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    sku character varying NOT NULL,
    shop_id uuid NOT NULL,
    name character varying NOT NULL,
    stock_count integer DEFAULT 0 NOT NULL,
    size character varying,
    color character varying,
    description character varying,
    ean character varying,
    manufacturer character varying,
    brand character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    categories json DEFAULT '[]'::json NOT NULL,
    material character varying,
    variants_count integer DEFAULT 0 NOT NULL,
    gender character varying,
    count character varying,
    scent character varying,
    offer_price_id uuid,
    original_price_id uuid,
    update_scheduled boolean DEFAULT false NOT NULL,
    original_sku character varying,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    master_id uuid
);


--
-- Name: raw_product_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.raw_product_data (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    product_id uuid NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: session_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.session_tokens (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    user_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: shadow_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shadow_products (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    product_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    name character varying(256),
    description character varying(2000),
    ean character varying(256),
    brand character varying(256),
    manufacturer character varying(256),
    color character varying(256),
    material character varying(256),
    size character varying(256),
    sku character varying(256),
    master_sku character varying(256),
    categories json DEFAULT '[]'::json NOT NULL,
    gender character varying(256),
    count character varying(256),
    scent character varying(256),
    master_id character varying(256),
    variant_ids json DEFAULT '[]'::json NOT NULL,
    offer_price_id uuid,
    original_price_id uuid,
    vendor_shop_configuration_id uuid NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    key_features json DEFAULT '{}'::json,
    platinum_keywords json DEFAULT '{}'::json,
    legal_disclaimer text,
    search_terms text
);


--
-- Name: shipping_carriers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipping_carriers (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    shipping_carrier integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: shipping_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipping_configurations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    vendor_method character varying,
    vendor_carrier character varying,
    shipping_method_id uuid,
    shipping_carrier_id uuid,
    vendor_shop_configuration_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: shipping_methods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipping_methods (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    shipping_method integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: shops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shops (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    account_id uuid NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    product_formatter character varying
);


--
-- Name: user_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_accounts (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    user_id uuid,
    account_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    email character varying NOT NULL,
    password_digest character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    password_reset_token uuid,
    password_reset_token_expires_at timestamp without time zone,
    password_reset_redirect_to character varying,
    name character varying,
    locale character varying DEFAULT 'en'::character varying NOT NULL
);


--
-- Name: vendor_locks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vendor_locks (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    target_id uuid NOT NULL,
    target_type character varying NOT NULL,
    vendor_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: vendor_product_matches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vendor_product_matches (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    product_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    matched boolean DEFAULT true NOT NULL,
    error json DEFAULT '[]'::json,
    vendor_shop_configuration_id uuid NOT NULL
);


--
-- Name: vendor_shop_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vendor_shop_configurations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    shop_id uuid NOT NULL,
    vendor_id uuid NOT NULL,
    type character varying DEFAULT 'VendorShopDispersalConfiguration'::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    auth_config text,
    currency_config json DEFAULT '{}'::json NOT NULL,
    config json DEFAULT '{}'::json NOT NULL,
    last_synced_at timestamp without time zone,
    price_adjustment_value double precision DEFAULT 0.0 NOT NULL,
    price_adjustment_type character varying DEFAULT 'percent'::character varying NOT NULL,
    enabled boolean DEFAULT true,
    webhooks json DEFAULT '{}'::json NOT NULL,
    orders_last_synced_at timestamp without time zone,
    name character varying
);


--
-- Name: vendors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vendors (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    token uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    channel_id uuid NOT NULL,
    name character varying,
    validation_url character varying,
    sku_formatter character varying DEFAULT 'Sku'::character varying
);


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id bigint NOT NULL,
    item_type character varying NOT NULL,
    item_id character varying NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp without time zone,
    object_changes text
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: import_maps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_maps ALTER COLUMN id SET DEFAULT nextval('public.import_maps_id_seq'::regclass);


--
-- Name: oauth_access_grants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_grants_id_seq'::regclass);


--
-- Name: oauth_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_tokens_id_seq'::regclass);


--
-- Name: oauth_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications ALTER COLUMN id SET DEFAULT nextval('public.oauth_applications_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: category_maps category_maps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_maps
    ADD CONSTRAINT category_maps_pkey PRIMARY KEY (id);


--
-- Name: vendor_product_matches channel_product_matches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_product_matches
    ADD CONSTRAINT channel_product_matches_pkey PRIMARY KEY (id);


--
-- Name: vendor_shop_configurations channel_store_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_shop_configurations
    ADD CONSTRAINT channel_store_configurations_pkey PRIMARY KEY (id);


--
-- Name: channels channels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (id);


--
-- Name: currency_conversions currency_conversions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_conversions
    ADD CONSTRAINT currency_conversions_pkey PRIMARY KEY (id);


--
-- Name: dispersals dispersals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dispersals
    ADD CONSTRAINT dispersals_pkey PRIMARY KEY (id);


--
-- Name: import_maps import_maps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_maps
    ADD CONSTRAINT import_maps_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: order_invoices order_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_invoices
    ADD CONSTRAINT order_invoices_pkey PRIMARY KEY (id);


--
-- Name: order_lines order_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_lines
    ADD CONSTRAINT order_lines_pkey PRIMARY KEY (id);


--
-- Name: order_raw_data order_raw_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_raw_data
    ADD CONSTRAINT order_raw_data_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: product_errors product_errors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_errors
    ADD CONSTRAINT product_errors_pkey PRIMARY KEY (id);


--
-- Name: product_images product_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT product_images_pkey PRIMARY KEY (id);


--
-- Name: product_prices product_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_prices
    ADD CONSTRAINT product_prices_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: raw_product_data raw_product_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.raw_product_data
    ADD CONSTRAINT raw_product_data_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: session_tokens session_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_tokens
    ADD CONSTRAINT session_tokens_pkey PRIMARY KEY (id);


--
-- Name: shadow_products shadow_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shadow_products
    ADD CONSTRAINT shadow_products_pkey PRIMARY KEY (id);


--
-- Name: shipping_carriers shipping_carriers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_carriers
    ADD CONSTRAINT shipping_carriers_pkey PRIMARY KEY (id);


--
-- Name: shipping_configurations shipping_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_configurations
    ADD CONSTRAINT shipping_configurations_pkey PRIMARY KEY (id);


--
-- Name: shipping_methods shipping_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_methods
    ADD CONSTRAINT shipping_methods_pkey PRIMARY KEY (id);


--
-- Name: shops shops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shops
    ADD CONSTRAINT shops_pkey PRIMARY KEY (id);


--
-- Name: user_accounts user_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_accounts
    ADD CONSTRAINT user_accounts_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vendor_locks vendor_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_locks
    ADD CONSTRAINT vendor_locks_pkey PRIMARY KEY (id);


--
-- Name: vendors vendors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: index_accounts_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_accounts_on_name ON public.accounts USING btree (name);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_addresses_on_country; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_addresses_on_country ON public.addresses USING btree (country);


--
-- Name: index_addresses_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_addresses_on_email ON public.addresses USING btree (email);


--
-- Name: index_category_maps_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_category_maps_on_name ON public.category_maps USING btree (name);


--
-- Name: index_category_maps_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_category_maps_on_position ON public.category_maps USING btree ("position");


--
-- Name: index_category_maps_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_category_maps_on_source ON public.category_maps USING btree (source);


--
-- Name: index_category_maps_on_vendor_shop_configuration_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_category_maps_on_vendor_shop_configuration_id ON public.category_maps USING btree (vendor_shop_configuration_id);


--
-- Name: index_channels_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_channels_on_name ON public.channels USING btree (name);


--
-- Name: index_currency_conversions_on_from_currency; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_currency_conversions_on_from_currency ON public.currency_conversions USING btree (from_currency);


--
-- Name: index_currency_conversions_on_rate; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_currency_conversions_on_rate ON public.currency_conversions USING btree (rate);


--
-- Name: index_currency_conversions_on_shop_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_currency_conversions_on_shop_id ON public.currency_conversions USING btree (shop_id);


--
-- Name: index_currency_conversions_on_to_currency; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_currency_conversions_on_to_currency ON public.currency_conversions USING btree (to_currency);


--
-- Name: index_dispersals_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dispersals_on_product_id ON public.dispersals USING btree (product_id);


--
-- Name: index_dispersals_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dispersals_on_state ON public.dispersals USING btree (state);


--
-- Name: index_dispersals_on_vendor_shop_configuration_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dispersals_on_vendor_shop_configuration_id ON public.dispersals USING btree (vendor_shop_configuration_id);


--
-- Name: index_import_maps_on_from; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_import_maps_on_from ON public.import_maps USING btree ("from");


--
-- Name: index_import_maps_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_import_maps_on_position ON public.import_maps USING btree ("position");


--
-- Name: index_import_maps_on_to; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_import_maps_on_to ON public.import_maps USING btree ("to");


--
-- Name: index_import_maps_on_vendor_shop_configuration_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_import_maps_on_vendor_shop_configuration_id ON public.import_maps USING btree (vendor_shop_configuration_id);


--
-- Name: index_oauth_access_grants_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_application_id ON public.oauth_access_grants USING btree (application_id);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON public.oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_application_id ON public.oauth_access_tokens USING btree (application_id);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON public.oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON public.oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON public.oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON public.oauth_applications USING btree (uid);


--
-- Name: index_order_invoices_on_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_order_invoices_on_order_id ON public.order_invoices USING btree (order_id);


--
-- Name: index_order_invoices_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_order_invoices_on_status ON public.order_invoices USING btree (status);


--
-- Name: index_order_lines_on_cents_with_vat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_order_lines_on_cents_with_vat ON public.order_lines USING btree (cents_with_vat);


--
-- Name: index_order_lines_on_cents_without_vat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_order_lines_on_cents_without_vat ON public.order_lines USING btree (cents_without_vat);


--
-- Name: index_order_lines_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_order_lines_on_product_id ON public.order_lines USING btree (product_id);


--
-- Name: index_order_lines_on_product_id_and_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_order_lines_on_product_id_and_order_id ON public.order_lines USING btree (product_id, order_id);


--
-- Name: index_order_lines_on_quantity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_order_lines_on_quantity ON public.order_lines USING btree (quantity);


--
-- Name: index_order_raw_data_on_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_order_raw_data_on_order_id ON public.order_raw_data USING btree (order_id);


--
-- Name: index_orders_on_billing_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_billing_address_id ON public.orders USING btree (billing_address_id);


--
-- Name: index_orders_on_currency; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_currency ON public.orders USING btree (currency);


--
-- Name: index_orders_on_delivery_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_delivery_address_id ON public.orders USING btree (delivery_address_id);


--
-- Name: index_orders_on_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_orders_on_order_id ON public.orders USING btree (order_id);


--
-- Name: index_orders_on_order_id_and_shop_id_and_vendor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_orders_on_order_id_and_shop_id_and_vendor_id ON public.orders USING btree (order_id, shop_id, vendor_id);


--
-- Name: index_orders_on_payment_fee; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_payment_fee ON public.orders USING btree (payment_fee);


--
-- Name: index_orders_on_purchased_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_purchased_at ON public.orders USING btree (purchased_at);


--
-- Name: index_orders_on_shipping_fee; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_shipping_fee ON public.orders USING btree (shipping_fee);


--
-- Name: index_orders_on_shop_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_shop_id ON public.orders USING btree (shop_id);


--
-- Name: index_orders_on_vat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_vat ON public.orders USING btree (vat);


--
-- Name: index_orders_on_vendor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_vendor_id ON public.orders USING btree (vendor_id);


--
-- Name: index_product_errors_on_severity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_errors_on_severity ON public.product_errors USING btree (severity);


--
-- Name: index_product_errors_on_shadow_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_errors_on_shadow_product_id ON public.product_errors USING btree (shadow_product_id);


--
-- Name: index_product_images_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_images_on_position ON public.product_images USING btree ("position");


--
-- Name: index_product_images_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_images_on_product_id ON public.product_images USING btree (product_id);


--
-- Name: index_product_images_on_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_images_on_url ON public.product_images USING btree (url);


--
-- Name: index_product_prices_on_cents; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_prices_on_cents ON public.product_prices USING btree (cents);


--
-- Name: index_product_prices_on_currency; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_prices_on_currency ON public.product_prices USING btree (currency);


--
-- Name: index_product_prices_on_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_prices_on_expires_at ON public.product_prices USING btree (expires_at);


--
-- Name: index_products_on_brand; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_brand ON public.products USING btree (brand);


--
-- Name: index_products_on_color; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_color ON public.products USING btree (color);


--
-- Name: index_products_on_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_count ON public.products USING btree (count);


--
-- Name: index_products_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_deleted_at ON public.products USING btree (deleted_at);


--
-- Name: index_products_on_ean; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_ean ON public.products USING btree (ean);


--
-- Name: index_products_on_gender; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_gender ON public.products USING btree (gender);


--
-- Name: index_products_on_manufacturer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_manufacturer ON public.products USING btree (manufacturer);


--
-- Name: index_products_on_material; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_material ON public.products USING btree (material);


--
-- Name: index_products_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_name ON public.products USING btree (name);


--
-- Name: index_products_on_offer_price_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_offer_price_id ON public.products USING btree (offer_price_id);


--
-- Name: index_products_on_original_price_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_original_price_id ON public.products USING btree (original_price_id);


--
-- Name: index_products_on_scent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_scent ON public.products USING btree (scent);


--
-- Name: index_products_on_shop_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_shop_id ON public.products USING btree (shop_id);


--
-- Name: index_products_on_size; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_size ON public.products USING btree (size);


--
-- Name: index_products_on_sku; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_products_on_sku ON public.products USING btree (sku);


--
-- Name: index_products_on_stock_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_stock_count ON public.products USING btree (stock_count);


--
-- Name: index_products_on_update_scheduled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_update_scheduled ON public.products USING btree (update_scheduled);


--
-- Name: index_products_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_updated_at ON public.products USING btree (updated_at);


--
-- Name: index_products_on_variants_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_variants_count ON public.products USING btree (variants_count);


--
-- Name: index_raw_product_data_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_raw_product_data_on_product_id ON public.raw_product_data USING btree (product_id);


--
-- Name: index_session_tokens_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_session_tokens_on_user_id ON public.session_tokens USING btree (user_id);


--
-- Name: index_shadow_products_on_brand; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shadow_products_on_brand ON public.shadow_products USING btree (brand);


--
-- Name: index_shadow_products_on_color; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shadow_products_on_color ON public.shadow_products USING btree (color);


--
-- Name: index_shadow_products_on_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shadow_products_on_count ON public.shadow_products USING btree (count);


--
-- Name: index_shadow_products_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shadow_products_on_deleted_at ON public.shadow_products USING btree (deleted_at);


--
-- Name: index_shadow_products_on_ean; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shadow_products_on_ean ON public.shadow_products USING btree (ean);


--
-- Name: index_shadow_products_on_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shadow_products_on_enabled ON public.shadow_products USING btree (enabled);


--
-- Name: index_shadow_products_on_gender; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shadow_products_on_gender ON public.shadow_products USING btree (gender);


--
-- Name: index_shadow_products_on_manufacturer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shadow_products_on_manufacturer ON public.shadow_products USING btree (manufacturer);


--
-- Name: index_shadow_products_on_master_sku; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shadow_products_on_master_sku ON public.shadow_products USING btree (master_sku);


--
-- Name: index_shadow_products_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shadow_products_on_name ON public.shadow_products USING btree (name);


--
-- Name: index_shadow_products_on_offer_price_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shadow_products_on_offer_price_id ON public.shadow_products USING btree (offer_price_id);


--
-- Name: index_shadow_products_on_original_price_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shadow_products_on_original_price_id ON public.shadow_products USING btree (original_price_id);


--
-- Name: index_shadow_products_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shadow_products_on_product_id ON public.shadow_products USING btree (product_id);


--
-- Name: index_shadow_products_on_scent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shadow_products_on_scent ON public.shadow_products USING btree (scent);


--
-- Name: index_shadow_products_on_size; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shadow_products_on_size ON public.shadow_products USING btree (size);


--
-- Name: index_shadow_products_on_sku; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shadow_products_on_sku ON public.shadow_products USING btree (sku);


--
-- Name: index_shadow_products_on_vendor_shop_configuration_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shadow_products_on_vendor_shop_configuration_id ON public.shadow_products USING btree (vendor_shop_configuration_id);


--
-- Name: index_shipping_configurations_on_vendor_shop_configuration_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipping_configurations_on_vendor_shop_configuration_id ON public.shipping_configurations USING btree (vendor_shop_configuration_id);


--
-- Name: index_shops_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shops_on_account_id ON public.shops USING btree (account_id);


--
-- Name: index_shops_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_shops_on_name ON public.shops USING btree (name);


--
-- Name: index_user_accounts_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_accounts_on_account_id ON public.user_accounts USING btree (account_id);


--
-- Name: index_user_accounts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_accounts_on_user_id ON public.user_accounts USING btree (user_id);


--
-- Name: index_user_accounts_on_user_id_and_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_accounts_on_user_id_and_account_id ON public.user_accounts USING btree (user_id, account_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_locale; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_locale ON public.users USING btree (locale);


--
-- Name: index_vendor_locks_on_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_locks_on_target_id ON public.vendor_locks USING btree (target_id);


--
-- Name: index_vendor_locks_on_target_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_locks_on_target_type ON public.vendor_locks USING btree (target_type);


--
-- Name: index_vendor_locks_on_vendor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_locks_on_vendor_id ON public.vendor_locks USING btree (vendor_id);


--
-- Name: index_vendor_locks_on_vendor_id_and_target_id_and_target_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_vendor_locks_on_vendor_id_and_target_id_and_target_type ON public.vendor_locks USING btree (vendor_id, target_id, target_type);


--
-- Name: index_vendor_product_matches_on_matched; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_product_matches_on_matched ON public.vendor_product_matches USING btree (matched);


--
-- Name: index_vendor_product_matches_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_product_matches_on_product_id ON public.vendor_product_matches USING btree (product_id);


--
-- Name: index_vendor_product_matches_on_vendor_shop_configuration_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_product_matches_on_vendor_shop_configuration_id ON public.vendor_product_matches USING btree (vendor_shop_configuration_id);


--
-- Name: index_vendor_shop_configurations_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_shop_configurations_on_deleted_at ON public.vendor_shop_configurations USING btree (deleted_at);


--
-- Name: index_vendor_shop_configurations_on_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_shop_configurations_on_enabled ON public.vendor_shop_configurations USING btree (enabled);


--
-- Name: index_vendor_shop_configurations_on_last_synced_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_shop_configurations_on_last_synced_at ON public.vendor_shop_configurations USING btree (last_synced_at);


--
-- Name: index_vendor_shop_configurations_on_orders_last_synced_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_shop_configurations_on_orders_last_synced_at ON public.vendor_shop_configurations USING btree (orders_last_synced_at);


--
-- Name: index_vendor_shop_configurations_on_price_adjustment_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_shop_configurations_on_price_adjustment_type ON public.vendor_shop_configurations USING btree (price_adjustment_type);


--
-- Name: index_vendor_shop_configurations_on_shop_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_shop_configurations_on_shop_id ON public.vendor_shop_configurations USING btree (shop_id);


--
-- Name: index_vendor_shop_configurations_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_shop_configurations_on_type ON public.vendor_shop_configurations USING btree (type);


--
-- Name: index_vendor_shop_configurations_on_vendor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_shop_configurations_on_vendor_id ON public.vendor_shop_configurations USING btree (vendor_id);


--
-- Name: index_vendors_on_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendors_on_channel_id ON public.vendors USING btree (channel_id);


--
-- Name: index_vendors_on_channel_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_vendors_on_channel_id_and_name ON public.vendors USING btree (channel_id, name);


--
-- Name: index_vendors_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendors_on_name ON public.vendors USING btree (name);


--
-- Name: index_vendors_on_sku_formatter; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendors_on_sku_formatter ON public.vendors USING btree (sku_formatter);


--
-- Name: index_vendors_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_vendors_on_token ON public.vendors USING btree (token);


--
-- Name: index_vendors_on_validation_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendors_on_validation_url ON public.vendors USING btree (validation_url);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON public.versions USING btree (item_type, item_id);


--
-- Name: oauth_access_tokens fk_rails_732cb83ab7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_rails_732cb83ab7 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: oauth_access_grants fk_rails_b4b53e07b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_rails_b4b53e07b8 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20180716220046'),
('20180716220117'),
('20180716220727'),
('20180716221026'),
('20180716221635'),
('20180716223232'),
('20180716224150'),
('20180716224425'),
('20180716230442'),
('20180718073728'),
('20180718084818'),
('20180718155120'),
('20180718160739'),
('20180718161310'),
('20180718200336'),
('20180718204731'),
('20180718211541'),
('20180718212423'),
('20180719054550'),
('20180719073337'),
('20180719074026'),
('20180719074759'),
('20180719131421'),
('20180719135029'),
('20180719140912'),
('20180719152959'),
('20180719153646'),
('20180719154320'),
('20180719160541'),
('20180719161227'),
('20180719200539'),
('20180729083147'),
('20180729110123'),
('20180729111117'),
('20180730083506'),
('20180730112054'),
('20180731113819'),
('20180731114256'),
('20180802214054'),
('20180803082524'),
('20180803100344'),
('20180803120436'),
('20180805124020'),
('20180806060445'),
('20180806095233'),
('20180806134116'),
('20180807100110'),
('20180808183732'),
('20180808205306'),
('20180810100356'),
('20180810124920'),
('20180810125445'),
('20180814190725'),
('20180815100238'),
('20180815100357'),
('20180815141830'),
('20180816083554'),
('20180816102310'),
('20180816113239'),
('20180817080921'),
('20180817133833'),
('20180817225134'),
('20180820055607'),
('20180820055645'),
('20180820101612'),
('20180821061043'),
('20180821074407'),
('20180821074627'),
('20180824091457'),
('20180824213031'),
('20180824213518'),
('20180827123958'),
('20180828122558'),
('20180829060808'),
('20180829063801'),
('20180831111415'),
('20180910073941'),
('20180914080012'),
('20180918093117'),
('20180918101515'),
('20180918102438'),
('20180918131331'),
('20180920082857'),
('20180920084322'),
('20181008095627'),
('20181008130054'),
('20181011142632'),
('20181015091105'),
('20181016123246'),
('20181016153534'),
('20181017090828'),
('20181017090957'),
('20181018115027'),
('20181018121114'),
('20181018125340'),
('20181018130300'),
('20181018140757'),
('20181022155516'),
('20181023211256'),
('20181025122816'),
('20181029143645'),
('20181029143646'),
('20181030101132'),
('20181102124815'),
('20181105143310'),
('20181106060132'),
('20181106064048'),
('20181106163943'),
('20181107071705'),
('20181107072217'),
('20181107072414'),
('20181107072747'),
('20181107084351'),
('20181107111227'),
('20181107131633'),
('20181108062604'),
('20181108102718'),
('20181123091822'),
('20181127105319'),
('20181127114318'),
('20181127123633'),
('20181128063707'),
('20181128065628'),
('20181128070529'),
('20181130130250'),
('20181130133935'),
('20181130141348'),
('20181130141628'),
('20181203091734'),
('20181205132436'),
('20181210064337'),
('20181210113650'),
('20181211070905'),
('20181217111922'),
('20181217113247'),
('20181217114033'),
('20181217132809'),
('20190204151521'),
('20190206093739'),
('20190207094942'),
('20190207094943'),
('20190207114438'),
('20190207114947'),
('20190207120311'),
('20190207120616'),
('20190207120640'),
('20190207122530'),
('20190207124138'),
('20190207135858'),
('20190207173304'),
('20190207173500'),
('20190208121232'),
('20190217075133'),
('20190218135635'),
('20190219092746'),
('20190219100702'),
('20190219100846'),
('20190219101132'),
('20190220090023'),
('20190225144109'),
('20190228100705'),
('20190311113147'),
('20190318112203'),
('20190404095223'),
('20190411102358'),
('20190417091037'),
('20190424134839'),
('20190513134335'),
('20190527083747'),
('20190527083944'),
('20190527084355'),
('20190527084523'),
('20190527084556'),
('20190527085110'),
('20190527085142'),
('20190527085227'),
('20190527085949'),
('20190527090023'),
('20190527133344'),
('20190527134029'),
('20190527134652');


