import admin from "../services/firebase";

/**
 * Model interface representing a user's profile information.
 */
export interface UserProfile {
  email: string;
  full_name?: string;
  bio?: string;
  birthdate?: admin.firestore.Timestamp;
  address_street?: string;
  address_unit_bldg?: string;
  address_barangay?: string;
  address_city?: string;
  address_province?: string;
  address_zip_code?: string;
  created_at?: admin.firestore.Timestamp;
  updated_at?: admin.firestore.Timestamp;
}
